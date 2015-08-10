require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do
  describe 'render' do
    it 'renders a single template with a given format' do
      InvoiceMailer.render(:html).must_include %(<h1>Banana</h1>)
    end
  end
end
