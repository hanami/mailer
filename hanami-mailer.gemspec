# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hanami/mailer/version"

Gem::Specification.new do |spec|
  spec.name          = "hanami-mailer"
  spec.version       = Hanami::Mailer::VERSION
  spec.authors       = ["Luca Guidi"]
  spec.email         = ["me@lucaguidi.com"]

  spec.summary       = "Mail for Ruby applications."
  spec.description   = "Mail for Ruby applications and Hanami mailers"
  spec.homepage      = "http://hanamirb.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -- lib/* CHANGELOG.md LICENSE.md README.md hanami-mailer.gemspec`.split($/)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.6.0"

  spec.add_dependency "hanami-utils", "~> 2.0.alpha"
  spec.add_dependency "tilt",         "~> 2.0", ">= 2.0.1"
  spec.add_dependency "mail",         "~> 2.6"

  spec.add_development_dependency "bundler", ">= 1.6", "< 3"
  spec.add_development_dependency "rake",  "~> 13"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "rubocop", "0.91"
end
