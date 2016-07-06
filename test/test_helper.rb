require 'rubygems'
require 'bundler/setup'

if ENV['COVERALL']
  require 'coveralls'
  Coveralls.wear!
end

require 'minitest/autorun'
$LOAD_PATH.unshift 'lib'
require 'hanami/mailer'

Hanami::Mailer.configure do
  root Pathname.new __dir__ + '/fixtures/templates'
end

Hanami::Mailer.class_eval do
  def self.reset!
    self.configuration = configuration.duplicate
    configuration.reset!
  end
end

Hanami::Mailer::Dsl.class_eval do
  def reset!
    @templates = {}
  end
end

require 'fixtures'

Hanami::Mailer.configure do
  root __dir__ + '/fixtures'
  delivery_method :test

  prepare do
    include DefaultSubject
  end
end.load!
