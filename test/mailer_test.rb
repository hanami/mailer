require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do
  describe '.load!' do
    describe 'when custom template is set' do
      before do
        InvoiceMailer.reset!
        Lotus::Mailer.reset!
        InvoiceMailer.template(:csv, 'welcome_mailer.csv.erb')
        Lotus::Mailer.load!
      end
      it 'will look up template' do
        template_test = InvoiceMailer.templates[:csv]
        template_test.must_be_kind_of(Lotus::Mailer::Template)
      end
      after do
        Lotus::Mailer.reset!
      end
    end
  end
end
