require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do
  describe 'render' do
    it 'renders a single template with a given format' do
      InvoiceMailer.new.render(:html).must_include %(<h1>Invoice template</h1>)
      LazyMailer.new.render(:html).must_include %(Hello World)
      LazyMailer.new.render(:haml).must_include %(This is a haml template)
      LazyMailer.new.render(:txt).must_include %(This is a txt template)
    end

    it 'renders a single template with context' do
      WelcomeMailer.new.render(:html).must_include %(Ahoy)
      WelcomeMailer.new.render(:txt).must_include %(Ahoy)
    end

    it 'renders a single template with locals' do
      luca = User.new('Luca')
      mailer = RenderMailer.new(user: luca)

      mailer.render(:html).must_include %(Luca)
    end
  end
end
