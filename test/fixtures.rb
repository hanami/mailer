class InvoiceMailer
  include Lotus::Mailer
  template 'invoice'
end

class RenderMailer
  include Lotus::Mailer
end

class TemplateEngineMailer
  include Lotus::Mailer
end

class CharsetMailer
  include Lotus::Mailer

  from    'noreply@example.com'
  to      'user@example.com'
  subject 'こんにちは'
end

class MissingFromMailer
  include Lotus::Mailer
  template 'missing'

  to      "recipient@example.com"
  subject "Hello"
end

class MissingToMailer
  include Lotus::Mailer
  template 'missing'

  from    "sender@example.com"
  subject "Hello"
end

class User < Struct.new(:name, :email); end

class LazyMailer
  include Lotus::Mailer
end

class MethodMailer
  include Lotus::Mailer

  from    :sender
  to      :recipient
  subject :greeting

  def greeting
    "Hello, #{ user.name }"
  end

  private

  def sender
    "hello-#{ user.name.downcase }@example.com"
  end

  def recipient
    user.email
  end
end

class WelcomeMailer
  include Lotus::Mailer

  from "noreply@sender.com"
  to ["noreply@recipient.com", "cc@recipient.com"]
  subject "Welcome"

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

module Users
  class Welcome
    include Lotus::Mailer
  end
end
