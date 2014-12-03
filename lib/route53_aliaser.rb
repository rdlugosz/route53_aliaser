require "route53_aliaser/version"
require "route53_aliaser/configuration"
require "route53_aliaser/route53_updater"
require "route53_aliaser/aliaser"

require "resolv"

require "aws-sdk"
require "active_support" #TODO: Can we break this dep?

module Route53Aliaser
  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Route53Aliaser::Configuration.new
    yield(config)
  end

  def self.update_alias_if_needed
    aliaser = Route53Aliaser::Aliaser.new(config)
    aliaser.call
  end
end
