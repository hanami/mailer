class InvoiceMailer
  include Lotus::Mailer
  template 'invoice.html.erb'
end

class RenderMailer
  include Lotus::Mailer
end

class LazyMailer
  include Lotus::Mailer
end

class User < Struct.new(:name); end

class WelcomeMailer
  include Lotus::Mailer

  from "noreply@sender.com"
  to "noreply@recipient.com"
  subject "Welcome"
  attach "render_mailer.html.erb"

  def greeting
    "Ahoy"
  end

  def prepare
    mail.attachments['invoice.pdf'] = '/path/to/invoice.pdf'
  end
end

class MandrillDeliveryMethod
  def initialize(options)
    @options = options
  end

  def deliver!(mail)
    @options.fetch(:deliveries).push(mail)
  end
end
