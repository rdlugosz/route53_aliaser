module Route53Aliaser
  class Aliaser
    attr_reader :config

    def initialize(config = Configuration.new)
      @config = config
    end

    def stale?
      config.cache.fetch(config.source_key).nil?
    end

    def call
      # NOOP if we haven't expired
      return unless stale?

      target_ips = get_ips(config.target_zone, config.target_key)
      source_ips = get_ips(config.source_zone, config.source_key)

      if target_ips == source_ips
        config.logger.debug "No Route 53 Update required."
      else
        config.logger.info "IPs for #{config.target_zone} #{target_ips} differ \
          from #{config.source_zone} #{source_ips}; will attempt to update."
        rt53 = Route53Updater.new(config)
        rt53.update_target(config.target_zone, source_ips, config.zone_id)
      end
    end

    private
    def get_ips(zone, key)
      ips = retrieve_ips_from_cache(key)
      if ips.empty?
        ips, ttl = get_ips_and_ttl_from_dns(zone)
        cache_results(key, zone, ips, ttl)
      end
      ips
    end

    def retrieve_ips_from_cache(key)
      cached_value = config.cache.fetch(key)
      if cached_value
        cached_value.split(',')
      else
        []
      end
    end

    def get_ips_and_ttl_from_dns(zone)
      ips, ttl = [], 0
      resources = Resolv::DNS.new.getresources(zone, Resolv::DNS::Resource::IN::A)
      if resources && resources.size > 0
        ips = resources.collect{|res| res.address.to_s}.sort
        ttl = resources.first.ttl
      end
      return ips, ttl
    rescue ResolvError => e
      config.logger.error e
      return ips, ttl
    end

    def cache_results(key, zone, ips, ttl)
      unless ips.empty?
        config.cache.write(key,
                           ips.join(','),
                           expires_in: ttl.seconds,
                           race_condition_ttl: 10
                          )
        config.logger.debug "Route53Aliaser Caching #{key}: #{ips} for #{ttl} seconds (ttl)"
      else
        config.logger.error "Route53Aliaser NOT Caching #{key} because no IPs were found."
      end
    end
  end
end
