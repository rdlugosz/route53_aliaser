module Route53Aliaser
  class Configuration
    attr_accessor :target_record, :source_record, :zone_id, :logger, :cache,
      :aws_access_key_id, :aws_secret_access_key

    def initialize
      @logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      @cache  = defined?(Rails) ? Rails.cache  : ActiveSupport::Cache::MemoryStore.new
    end

    def target_key
      "rt53_#{target_record}_ips"
    end

    def source_key
      "rt53_#{source_record}_ips"
    end
  end
end
