class InvoiceMailer
  include Lotus::Mailer
  template :html, 'invoice.html.erb'
end

class RenderMailer
  include Lotus::Mailer
end

class LazyMailer
  include Lotus::Mailer
end

class StringMailer
  include Lotus::Mailer

  from "noreply@example.com"
  to "noreply1@example.com"
  subject "This is the subject"
end

class ProcMailer
  include Lotus::Mailer

  from -> { customized_sender }
  to -> { customized_receiver }
  subject -> { customized_subject }

  def customized_sender
    "user_sender@example.com"
  end

  def customized_receiver
    "user_receiver@example.com"
  end

  def customized_subject
    "This is the subject"
  end
end

class ArrayMailer
  include Lotus::Mailer

  to ["noreply1@example.com", "noreply2@example.com"]
end

class WelcomeMailer
  include Lotus::Mailer

  from "noreply@sender.com"
  to "noreply@recipient.com"
  subject "Welcome"

  def greeting
    "Ahoy"
  end
end

class User < Struct.new(:name); end

class SubscriptionMailer
  include Lotus::Mailer

  from "noreply@sender.com"
  to "noreply@recipient.com"
  subject "Prepare test"

  def prepare
    mail.attachments['invoice.pdf'] = '/path/to/invoice.pdf'
  end
end
