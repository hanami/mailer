# frozen_string_literal: true
require 'bundler/setup'
require 'hanami/mailer'

configuration = Hanami::Mailer::Configuration.new do |config|
  config.root            = File.expand_path(__dir__, "base")
  config.delivery_method = :test
end

class Invoice
  attr_reader :id, :number

  def initialize(id, number)
    @id     = id
    @number = number
    freeze
  end
end

class User
  attr_reader :name, :email

  def initialize(name, email)
    @name  = name
    @email = email
    freeze
  end
end

class InvoiceMailer < Hanami::Mailer
  template "invoice"

  from "invoices@domain.test"
  to ->(locals) { locals.fetch(:user).email }

  subject ->(locals) { "Invoice ##{locals.fetch(:invoice).number}" }
end

configuration = Hanami::Mailer.finalize(configuration)

invoice = Invoice.new(1, 23)
user    = User.new("Luca", "luca@domain.test")

mailer = InvoiceMailer.new(configuration: configuration)
puts mailer.deliver(invoice: invoice, user: user)
