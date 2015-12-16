require 'test_helper'

describe Lotus::Mailer do
  describe '.deliver' do
    before do
      Lotus::Mailer.deliveries.clear
    end

    it 'can deliver with specified charset' do
      CharsetMailer.deliver(charset: charset = 'iso-2022-jp')

      mail = Lotus::Mailer.deliveries.first
      mail.charset.must_equal             charset
      mail.parts.first.charset.must_equal charset
    end

    it "raises error when 'from' isn't specified" do
      -> { MissingFromMailer.deliver }.must_raise Lotus::Mailer::MissingDeliveryDataError
    end

    it "raises error when 'to' isn't specified" do
      -> { MissingToMailer.deliver }.must_raise Lotus::Mailer::MissingDeliveryDataError
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
      end

      it 'interprets the prepare statement' do
        attachment = @mail.attachments['invoice.pdf']

        attachment.must_be_kind_of(Mail::Part)

        attachment.must_be :attachment?
        attachment.wont_be :inline?
        attachment.wont_be :multipart?

        attachment.filename.must_equal     'invoice.pdf'
        attachment.content_type.must_equal 'application/pdf; charset=UTF-8; filename=invoice.pdf'
      end
    end

    describe 'test delivery with methods' do
      before do
        @user = User.new('Name', 'student@deigirls.com')
        MethodMailer.deliver(user: @user)

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

    describe 'multipart' do
      after do
        Lotus::Mailer.deliveries.clear
      end

      it 'delivers all the parts by default' do
        WelcomeMailer.deliver

        mail = Lotus::Mailer.deliveries.first
        body = mail.body.encoded

        body.must_include %(<h1>Hello World!</h1>)
        body.must_include %(This is a txt template)
      end

      it 'can deliver only the text part' do
        WelcomeMailer.deliver(format: :txt)

        mail = Lotus::Mailer.deliveries.first
        body = mail.body.encoded

        body.wont_include %(<h1>Hello World!</h1>)
        body.must_include %(This is a txt template)
      end

      it 'can deliver only the html part' do
        WelcomeMailer.deliver(format: :html)

        mail = Lotus::Mailer.deliveries.first
        body = mail.body.encoded

        body.must_include %(<h1>Hello World!</h1>)
        body.wont_include %(This is a txt template)
      end
    end

    describe 'custom delivery' do
      before do
        @options = options = { deliveries: [] }

        # Lotus::Mailer.reset!
        # Lotus::Mailer.configure do
        #   delivery_method MandrillDeliveryMethod, options
        # end.load!

        WelcomeMailer.deliver

        @mail = options.fetch(:deliveries).first
      end

      it 'delivers the mail'
      # it 'delivers the mail' do
      #   @options.fetch(:deliveries).length.must_equal 1
      # end

      # it 'sends the correct information' do
      #   @mail.from.must_equal ['noreply@sender.com']
      #   @mail.to.must_equal ['noreply@recipient.com']
      #   @mail.subject.must_equal "Welcome"
      # end

      # it 'has the correct templates' do
      #   @mail.html_part.to_s.must_include %(template)
      #   @mail.text_part.to_s.must_include %(template)
      # end

      # it 'interprets the prepare statement' do
      #   @mail.attachments['invoice.pdf'].wont_be_nil
      # end

      # it 'adds the attachment to the mail object' do
      #   @mail.attachments['render_mailer.html.erb'].wont_be_nil
      # end
    end
  end
end
