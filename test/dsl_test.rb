require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do
  before do
    Lotus::Mailer.reset!
  end

  describe '#root' do
    describe 'when a value is given' do
      it 'sets it as a Pathname' do
        RenderMailer.root 'test'
        RenderMailer.configuration.root.must_equal(RenderMailer.root)
      end
    end
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
        template_test = LazyMailer.templates[:haml]
        template_test.file.must_equal("#{ LazyMailer.root }/lazy_mailer.haml.erb")
      end
    end
  end
end
