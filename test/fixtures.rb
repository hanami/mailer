class InvoiceMailer
  include Lotus::Mailer
  template :html, 'invoice.html.erb'
end

class RenderMailer
  include Lotus::Mailer
end
