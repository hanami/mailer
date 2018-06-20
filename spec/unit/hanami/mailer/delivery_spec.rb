RSpec.describe Hanami::Mailer do
  describe '.deliver' do
    before do
      Hanami::Mailer.deliveries.clear
    end

    it 'can deliver with specified charset' do
      CharsetMailer.deliver(charset: charset = 'iso-2022-jp')

      mail = Hanami::Mailer.deliveries.first
      expect(mail.charset).to             eq(charset)
      expect(mail.parts.first.charset).to eq(charset)
    end

    it "raises error when 'from' isn't specified" do
      expect { MissingFromMailer.deliver }.to raise_error(Hanami::Mailer::MissingDeliveryDataError)
    end

    it "raises error when 'to' isn't specified" do
      expect { MissingToMailer.deliver }.to raise_error(Hanami::Mailer::MissingDeliveryDataError)
    end

    it "doesn't raise error when 'cc' is specified but 'to' isn't" do
      CcOnlyMailer.deliver
    end

    it "doesn't raise error when 'bcc' is specified but 'to' isn't" do
      BccOnlyMailer.deliver
    end

    it "lets other errors to bubble up" do
      mailer = CharsetMailer.new({})
      mail   = Class.new do
        def deliver
          raise ArgumentError, "ouch"
        end
      end.new

      expect(mailer).to receive(:mail).and_return(mail)
      expect { mailer.deliver }.to raise_error(ArgumentError, "ouch")
    end

    describe 'test delivery with hardcoded values' do
      before do
        WelcomeMailer.deliver
        @mail = Hanami::Mailer.deliveries.first
      end

      after do
        Hanami::Mailer.deliveries.clear
      end

      it 'delivers the mail' do
        expect(Hanami::Mailer.deliveries.length).to eq(1)
      end

      it 'sends the correct information' do
        expect(@mail.from).to     eq(['noreply@sender.com'])
        expect(@mail.to).to       eq(['noreply@recipient.com', 'owner@recipient.com'])
        expect(@mail.cc).to       eq(['cc@recipient.com'])
        expect(@mail.bcc).to      eq(['bcc@recipient.com'])
        expect(@mail.reply_to).to eq(['reply_to@recipient.com'])
        expect(@mail.subject).to  eq('Welcome')
      end

      it 'has the correct templates' do
        expect(@mail.html_part.to_s).to include(%(template))
        expect(@mail.text_part.to_s).to include(%(template))
      end

      it 'interprets the prepare statement' do
        attachment = @mail.attachments['invoice.pdf']

        expect(attachment).to be_kind_of(Mail::Part)

        expect(attachment).to be_attachment
        expect(attachment).to_not be_inline
        expect(attachment).to_not be_multipart

        expect(attachment.filename).to eq('invoice.pdf')

        expect(attachment.content_type).to match('application/pdf')
        expect(attachment.content_type).to match('filename=invoice.pdf')
      end
    end

    describe 'test delivery with methods' do
      before do
        @user = User.new('Name', 'student@deigirls.com')
        MethodMailer.deliver(user: @user)

        @mail = Hanami::Mailer.deliveries.first
      end

      after do
        Hanami::Mailer.deliveries.clear
      end

      it 'delivers the mail' do
        expect(Hanami::Mailer.deliveries.length).to eq(1)
      end

      it 'sends the correct information' do
        expect(@mail.from).to    eq(["hello-#{@user.name.downcase}@example.com"])
        expect(@mail.to).to      eq([@user.email])
        expect(@mail.subject).to eq("Hello, #{@user.name}")
      end
    end

    describe 'multipart' do
      after do
        Hanami::Mailer.deliveries.clear
      end

      it 'delivers all the parts by default' do
        WelcomeMailer.deliver

        mail = Hanami::Mailer.deliveries.first
        body = mail.body.encoded

        expect(body).to include(%(<h1>Hello World!</h1>))
        expect(body).to include(%(This is a txt template))
      end

      it 'can deliver only the text part' do
        WelcomeMailer.deliver(format: :txt)

        mail = Hanami::Mailer.deliveries.first
        body = mail.body.encoded

        expect(body).to_not include(%(<h1>Hello World!</h1>))
        expect(body).to     include(%(This is a txt template))
      end

      it 'can deliver only the html part' do
        WelcomeMailer.deliver(format: :html)

        mail = Hanami::Mailer.deliveries.first
        body = mail.body.encoded

        expect(body).to     include(%(<h1>Hello World!</h1>))
        expect(body).to_not include(%(This is a txt template))
      end
    end

    describe 'custom delivery' do
      before do
        @options = options = { deliveries: [] }

        # Hanami::Mailer.reset!
        # Hanami::Mailer.configure do
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
