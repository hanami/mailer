require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do
  before do
    Lotus::Mailer.reset!
  end

  describe '#template' do
    describe 'set the correct templates' do
      it 'has the template in the hash' do
        template_test = InvoiceMailer.templates[:html]
        template_test.file.must_equal("#{ InvoiceMailer.root }/invoice.html.erb")
      end
    end
  end

  describe '#templates' do
    describe 'finds all the templates with the same name' do
      it 'has the template in the hash' do
        template_test = LazyMailer.templates[:html]
        template_test.file.must_equal("#{ LazyMailer.root }/lazy_mailer.html.erb")
      end
    end
  end
end
