require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do

  before do
    Lotus::Mailer.reset!
  end

  # describe '.template' do
  #   describe 'when given a template format and path' do
  #     it 'sets the template in the templates hash' do
  #       InvoiceMailer.template(:csv, 'welcome_mailer.csv.erb')
  #       template_test = InvoiceMailer.templates[:csv]
  #       template_test.must_be_kind_of(Lotus::Mailer::Template)
  #     end
  #   end
  #
  #   describe 'when given only template format' do
  #     describe 'when the given template is already defined' do
  #       before do
  #         InvoiceMailer.template(:html, 'invoice.html.erb')
  #       end
  #       it 'returns the template' do
  #         template = InvoiceMailer.template(:html)
  #         template.must_be_kind_of(Lotus::Mailer::Template)
  #       end
  #     end
  #   end
  # end

  describe '.templates' do
    describe 'returns mailer templates hash' do
      it 'returns a templates hash' do
        formats = LazyMailer.templates.keys
        formats.count.must_equal(3)
        formats.must_include(:txt)
        formats.must_include(:html)
        formats.must_include(:haml)
        template_test = LazyMailer.templates[:html]
        template_test.must_be_kind_of(Lotus::Mailer::Template)
      end
    end
  end

  describe '.from' do
    describe 'when given a string' do
      it 'sets the address in the variable' do
        LazyMailer.from 'rosa@example.com'
        LazyMailer.from.must_equal 'rosa@example.com'
      end
    end
    describe 'when given a proc' do
      it 'sets the address in the variable' do
        LazyMailer.from -> { 'user_sender@example.com' }
        LazyMailer.from.must_equal 'user_sender@example.com'
      end
    end

    describe 'when given a proc that references a method' do
      before do
        LazyMailer.class_eval do
          from -> { customized_sender }

          def customized_sender
            "sender@example.com"
          end
        end
      end

      it 'sets the sender address to the return value of the method' do
        LazyMailer.from.must_equal 'sender@example.com'
      end
    end
  end

  describe '.to' do
    describe 'when given a string' do
      it 'sets the recipients in the variable' do
        LazyMailer.to 'ines@example.com'
        LazyMailer.to.must_equal 'ines@example.com'
      end
    end
    describe 'when given an array' do
      it 'sets the recipients in the variable' do
        LazyMailer.to ["noreply1@example.com", "noreply2@example.com"]
        LazyMailer.to.must_equal 'noreply1@example.com,noreply2@example.com'
      end
    end
    describe 'when given a proc' do
      it 'has the address in the variable' do
        LazyMailer.to -> { 'user_recipient@example.com' }
        LazyMailer.to.must_equal 'user_recipient@example.com'
      end
    end

    describe 'when given a proc that references a method' do
      before do
        LazyMailer.class_eval do
          to -> { customized_recipient }

          def customized_recipient
            "recipient@example.com"
          end
        end
      end
      it 'sets the correct recipient address' do
        LazyMailer.to.must_equal 'recipient@example.com'
      end
    end
  end

  describe '.subject' do
    describe 'when given a string' do
      it 'sets the subject in the variable' do
        LazyMailer.subject 'Team DEIGirls'
        LazyMailer.subject.must_equal 'Team DEIGirls'
      end
    end
    describe 'when given a proc' do
      it 'sets the subject in the variable' do
        LazyMailer.subject -> { 'Trung is awesome' }
        LazyMailer.subject.must_equal 'Trung is awesome'
      end
    end

    describe 'when given a Proc that references to a method' do
      before do
        LazyMailer.class_eval do
          subject -> { custom_subject }

          def custom_subject
            "Lotus rocks!"
          end
        end
      end

      it 'sets the subject to the return value of the method' do
        LazyMailer.subject.must_equal 'Lotus rocks!'
      end
    end
  end

end
