require "route53_aliaser/version"
require "route53_aliaser/configuration"
require "route53_aliaser/route53_updater"
require "route53_aliaser/aliaser"

require "aws-sdk"

module Route53Aliaser
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Route53Aliaser::Configuration.new
    yield(configuration)
  end
end
