require 'test_helper'

describe Lotus::Mailer do
  describe '.deliver' do
    before do
      Lotus::Mailer.deliveries.clear
    end

    describe 'test delivery with hardcoded values' do
      before do
        WelcomeMailer.deliver
        @mail = Lotus::Mailer.deliveries.first
      end

      after do
        Lotus::Mailer.deliveries.clear
      end

      it 'delivers the mail' do
        Lotus::Mailer.deliveries.length.must_equal 1
      end

      it 'sends the correct information' do
        @mail.from.must_equal ['noreply@sender.com']
        @mail.to.must_equal   ['noreply@recipient.com', 'cc@recipient.com']
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

    describe 'test delivery with methods' do
      before do
        @user = User.new('Name', 'student@deigirls.com')
        MethodMailer.deliver(locals: {user: @user})

        @mail = Lotus::Mailer.deliveries.first
      end

      after do
        Lotus::Mailer.deliveries.clear
      end

      it 'delivers the mail' do
        Lotus::Mailer.deliveries.length.must_equal 1
      end

      it 'sends the correct information' do
        @mail.from.must_equal    ["hello-#{ @user.name.downcase }@example.com"]
        @mail.to.must_equal      [@user.email]
        @mail.subject.must_equal "Hello, #{ @user.name }"
      end
    end

    describe 'test delivery with methods' do
      before do
        @user = User.new('Ines', 'ines@deigirls.com')
        MethodMailer.deliver(locals: {user: @user})

        @mail = Lotus::Mailer.deliveries.first
      end

      after do
        Lotus::Mailer.deliveries.clear
      end

      it 'delivers the mail' do
        Lotus::Mailer.deliveries.length.must_equal 1
      end

      it 'sends the correct information' do
        @mail.from.must_equal    ["hello-#{ @user.name.downcase }@example.com"]
        @mail.to.must_equal      [@user.email]
        @mail.subject.must_equal "Hello, #{ @user.name }"
      end
    end

    # describe 'custom delivery' do
    #   before do
    #     @options = options = { deliveries: [] }

    #     Lotus::Mailer.reset!
    #     Lotus::Mailer.configure do
    #       delivery_method MandrillDeliveryMethod, options
    #     end.load!

    #     WelcomeMailer.deliver

    #     @mail = options.fetch(:deliveries).first
    #   end

    #   after do
    #     Lotus::Mailer.reset!
    #   end

    #   it 'delivers the mail' do
    #     @options.fetch(:deliveries).length.must_equal 1
    #   end

    #   it 'sends the correct information' do
    #     @mail.from.must_equal ['noreply@sender.com']
    #     @mail.to.must_equal ['noreply@recipient.com']
    #     @mail.subject.must_equal "Welcome"
    #   end

    #   it 'has the correct templates' do
    #     @mail.html_part.to_s.must_include %(template)
    #     @mail.text_part.to_s.must_include %(template)
    #     @mail.attachments['welcome_mailer.csv'].wont_be_nil
    #   end

    #   it 'interprets the prepare statement' do
    #     @mail.attachments['invoice.pdf'].wont_be_nil
    #   end

    #   it 'adds the attachment to the mail object' do
    #     @mail.attachments['render_mailer.html.erb'].wont_be_nil
    #   end
    # end
  end
end
