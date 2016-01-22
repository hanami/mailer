lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hanami/mailer/version'

Gem::Specification.new do |spec|
  spec.name          = 'hanami-mailer'
  spec.version       = Hanami::Mailer::VERSION
  spec.authors       = ['Luca Guidi', 'Ines Coelho', 'Rosa Faria']
  spec.email         = ['me@lucaguidi.com', 'ines.opcoelho@gmail.com', 'rosa1853@live.com']

  spec.summary       = %q{Mail for Ruby applications.}
  spec.description   = %q{Mail for Ruby applications and Hanami mailers}
  spec.homepage      = 'http://hanamirb.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -- lib/* CHANGELOG.md LICENSE.md README.md hanami-mailer.gemspec`.split($/)
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.2.0'

  spec.add_dependency 'hanami-utils', '~> 0.7'
  spec.add_dependency 'tilt',         '~> 2.0', '>= 2.0.1'
  spec.add_dependency 'mail',         '~> 2.5'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.7'
end
