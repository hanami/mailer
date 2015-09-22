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

  def greeting
    "Ahoy"
  end
end

class MandrillDeliveryMethod
  def initialize(options)
    @options = options
  end

  def deliver!(mail)
    # ...
  end
end
