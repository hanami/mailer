class InvoiceMailer
  include Hanami::Mailer
  template 'invoice'
end

class RenderMailer
  include Hanami::Mailer
end

class TemplateEngineMailer
  include Hanami::Mailer
end

class CharsetMailer
  include Hanami::Mailer

  from    'noreply@example.com'
  to      'user@example.com'
  subject 'こんにちは'
end

class MissingFromMailer
  include Hanami::Mailer
  template 'missing'

  to      'recipient@example.com'
  subject 'Hello'
end

class MissingToMailer
  include Hanami::Mailer
  template 'missing'

  from    'sender@example.com'
  subject 'Hello'
end

class CcOnlyMailer
  include Hanami::Mailer
  template 'missing'

  cc      'recipient@example.com'
  from    'sender@example.com'
  subject 'Hello'
end

class BccOnlyMailer
  include Hanami::Mailer
  template 'missing'

  bcc      'recipient@example.com'
  from    'sender@example.com'
  subject 'Hello'
end

User = Struct.new(:name, :email)

class LazyMailer
  include Hanami::Mailer
end

class MethodMailer
  include Hanami::Mailer

  from    :sender
  to      :recipient
  subject :greeting

  def greeting
    "Hello, #{user.name}"
  end

  private

  def sender
    "hello-#{user.name.downcase}@example.com"
  end

  def recipient
    user.email
  end
end

class WelcomeMailer
  include Hanami::Mailer

  from     'noreply@sender.com'
  to       ['noreply@recipient.com', 'owner@recipient.com']
  cc       'cc@recipient.com'
  bcc      'bcc@recipient.com'
  reply_to 'reply_to@recipient.com'

  subject 'Welcome'

  def greeting
    'Ahoy'
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
    include Hanami::Mailer
  end
end

module DefaultSubject
  def self.included(mailer)
    mailer.subject 'default subject'
  end
end
