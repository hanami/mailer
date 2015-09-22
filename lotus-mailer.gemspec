lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lotus/mailer/version'

Gem::Specification.new do |spec|
  spec.name          = 'lotus-mailer'
  spec.version       = Lotus::Mailer::VERSION
  spec.authors       = ['Luca Guidi', 'Ines Coelho', 'Rosa Faria']
  spec.email         = ['me@lucaguidi.com', 'ines.opcoelho@gmail.com', 'rosa1853@live.com']

  spec.summary       = %q{Mail for Ruby applications.}
  spec.description   = %q{Mail for Ruby applications and Lotus mailers}
  spec.homepage      = 'http://lotusrb.org'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -- lib/* CHANGELOG.md LICENSE.md README.md lotus-mailer.gemspec`.split($/)
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'lotus-utils', '~> 0.5'
  spec.add_dependency 'tilt',        '~> 2.0', '>= 2.0.1'
  spec.add_dependency 'mail'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.7'
end
