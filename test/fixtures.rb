class InvoiceMailer
  include Lotus::Mailer
  template :html, 'invoice.html.erb'
  #Lotus::Mailer.load!
end

class RenderMailer
  include Lotus::Mailer
end

class LazyMailer
  include Lotus::Mailer
end
