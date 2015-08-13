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

  describe '#from' do
    describe 'sets the correct sender address given a string' do
      it 'has the address in the variable' do
        StringMailer.from.must_equal 'noreply@example.com'
      end
    end
    describe 'sets the correct sender address given a proc' do
      it 'has the address in the variable' do
        ProcMailer.from.must_equal 'user_sender@example.com'
      end
    end
  end

  describe '#to' do
    describe 'sets the correct recipients given a string' do
      it 'has the recipients in the variable' do
        StringMailer.to.must_equal 'noreply1@example.com'
      end
    end
    describe 'sets the correct recipients given an array' do
      it 'has the recipients in the variable' do
        ArrayMailer.to.must_equal 'noreply1@example.com,noreply2@example.com'
      end
    end
    describe 'sets the correct recipients given a proc' do
      it 'has the recipients in the variable' do
        ProcMailer.to.must_equal 'user_receiver@example.com'
      end
    end
  end

  describe '#subject' do
    describe 'sets the correct subject given a string' do
      it 'has the subject in the variable' do
        StringMailer.subject.must_equal 'This is the subject'
      end
    end
    describe 'sets the correct subject given a proc' do
      it 'has the subject in the variable' do
        ProcMailer.subject.must_equal 'This is the subject'
      end
    end
  end

end
