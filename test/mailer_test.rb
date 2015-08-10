require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do
  before do
    Lotus::Mailer.reset!
  end

  describe '#template' do
    describe 'set_the_correct_templates' do
      it 'has_the_template_in_the_hash' do
        templateTest = InvoiceMailer.templates[:html]
        templateTest.file.must_equal("#{ InvoiceMailer.root }/invoice.html.erb")
      end
    end
  end

  describe '#templates' do
    describe 'finds_all_the_templates_with_the_same_name' do
      it 'has_the_template_in_the_hash' do
        templateTest = LazyMailer.templates[:html]
        templateTest.file.must_equal("#{ LazyMailer.root }/lazy_mailer.html.erb")
      end
    end
  end
end
