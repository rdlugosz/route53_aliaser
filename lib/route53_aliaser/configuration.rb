module Route53Aliaser
  class Configuration
    attr_accessor :target_zone, :source_zone, :zone_id, :logger, :cache

    def initialize
      @logger = Logger.new(STDOUT)
      @cache  = ActiveSupport::Cache::MemoryStore.new
    end

    def target_key
      "rt53_#{target_zone}_ips"
    end

    def source_key
      "rt53_#{source_zone}_ips"
    end
  end
end
