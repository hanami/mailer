require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do
  describe 'render' do
    it 'renders a single template with a given format' do
      InvoiceMailer.render(:html).must_include %(<h1>Invoice template</h1>)
      LazyMailer.render(:html).must_include %(Hello World)
      LazyMailer.render(:haml).must_include %(This is a haml template)
      LazyMailer.render(:txt).must_include %(This is a txt template)
    end
  end
end
