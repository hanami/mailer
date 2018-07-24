# frozen_string_literal: true

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

Hanami::Mailer.configure do
  root __dir__ + "/fixtures"
  delivery_method :test

  prepare do
    include DefaultSubject
  end
end.load!
