require 'rubygems'
require 'bundler/setup'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    command_name 'test'
    add_filter   'test'
  end
end

require 'minitest/autorun'
$:.unshift 'lib'
require 'lotus/mailer'

Lotus::Mailer.configure do
  root Pathname.new __dir__ + '/fixtures/templates'
end

Lotus::Mailer.class_eval do
  def self.reset!
    self.configuration = configuration.duplicate
    configuration.reset!
  end
end

Lotus::Mailer::Dsl.class_eval do
  def reset!
    @templates = Hash.new
  end
end

require 'fixtures'

Lotus::Mailer.configure do
  root __dir__ + '/fixtures'
  delivery_method :test

  prepare do
    include DefaultSubject
  end
end.load!
