# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'route53_aliaser/version'

Gem::Specification.new do |spec|
  spec.name          = "route53_aliaser"
  spec.version       = Route53Aliaser::VERSION
  spec.authors       = ["Ryan Dlugosz"]
  spec.email         = ["ryan@dlugosz.net"]
  spec.summary       = %q{Simulate DNS ALIAS-record support for apex zones (a.k.a. bare / naked / root domains) via Amazon Route 53}
  spec.description   = %q{NOTE: This software is no longer being maintained and may have issues. Please check the Readme.}
  spec.homepage      = "https://github.com/rdlugosz/route53_aliaser"
  spec.license       = "MIT"

  spec.post_install_message = "WARNING!! Route53Aliaser is no longer being maintained and may have issues! Please see the Readme."

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"

  spec.add_dependency "aws-sdk", "~> 1.57"
  spec.add_dependency "activesupport", ">= 3.2"
end
