require 'test_helper'

describe Lotus::Mailer do
  describe '.deliver' do
    describe 'test delivery' do
      before do
        Lotus::Mailer.reset!
        Lotus::Mailer.configure do
          delivery_method :test
        end.load!

        Lotus::Mailer.deliveries.clear
        WelcomeMailer.deliver

        @mail = Lotus::Mailer.deliveries.first
      end

      after do
        Lotus::Mailer.deliveries.clear
        Lotus::Mailer.reset!
      end

      it 'delivers the mail' do
        Lotus::Mailer.deliveries.length.must_equal 1
      end

      it 'sends the correct information' do
        @mail.from.must_equal ['noreply@sender.com']
        @mail.to.must_equal ['noreply@recipient.com']
        @mail.subject.must_equal "Welcome"
      end

      it 'has the correct templates' do
        @mail.html_part.to_s.must_include %(template)
        @mail.text_part.to_s.must_include %(template)
        @mail.attachments['welcome_mailer.csv'].wont_be_nil
      end

      it 'interprets the prepare statement' do
        @mail.attachments['invoice.pdf'].wont_be_nil
      end

      it 'adds the attachment to the mail object' do
        @mail.attachments['render_mailer.html.erb'].wont_be_nil
      end
    end

    describe 'custom delivery' do
      before do
        @options = options = { deliveries: [] }

        Lotus::Mailer.reset!
        Lotus::Mailer.configure do
          delivery_method MandrillDeliveryMethod, options
        end.load!

        WelcomeMailer.deliver

        @mail = options.fetch(:deliveries).first
      end

      after do
        Lotus::Mailer.reset!
      end

      it 'delivers the mail' do
        @options.fetch(:deliveries).length.must_equal 1
      end

      it 'sends the correct information' do
        @mail.from.must_equal ['noreply@sender.com']
        @mail.to.must_equal ['noreply@recipient.com']
        @mail.subject.must_equal "Welcome"
      end

      it 'has the correct templates' do
        @mail.html_part.to_s.must_include %(template)
        @mail.text_part.to_s.must_include %(template)
        @mail.attachments['welcome_mailer.csv'].wont_be_nil
      end

      it 'interprets the prepare statement' do
        @mail.attachments['invoice.pdf'].wont_be_nil
      end

      it 'adds the attachment to the mail object' do
        @mail.attachments['render_mailer.html.erb'].wont_be_nil
      end
    end
  end
end
