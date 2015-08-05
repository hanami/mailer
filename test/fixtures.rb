class InvoiceMailer
  include Lotus::Mailer
end

class RenderMailer
  include Lotus::Mailer
end

class TemplateTestMailer
  include Lotus::Mailer
  template :html, 'ola.html.erb'
end
