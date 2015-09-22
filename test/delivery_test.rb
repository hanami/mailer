describe Lotus::Mailer do
  describe '#deliver' do
    before do
      Lotus::Mailer.reset!
      Lotus::Mailer.configure do
        delivery_method :test
      end.load!
      Mail::TestMailer.deliveries.clear

      class WelcomeMailer
        include Lotus::Mailer

        from "noreply@sender.com"
        to "noreply@recipient.com"
        subject "Welcome"
        attach "render_mailer.html.erb"

        def greeting
          "Ahoy"
        end

        def prepare
          mail.attachments['invoice.pdf'] = '/path/to/invoice.pdf'
        end
      end

      WelcomeMailer.deliver
    end

    it 'delivers the mail' do
      Mail::TestMailer.deliveries.length.must_equal 1
    end

    it 'sends the correct information' do
      Mail::TestMailer.deliveries.first.from.must_equal ['noreply@sender.com']
      Mail::TestMailer.deliveries.first.to.must_equal ['noreply@recipient.com']
      Mail::TestMailer.deliveries.first.subject.must_equal "Welcome"
    end

    it 'has the correct templates' do
      Mail::TestMailer.deliveries.first.html_part.to_s.must_include %(template)
      Mail::TestMailer.deliveries.first.text_part.to_s.must_include %(template)
      refute_nil(Mail::TestMailer.deliveries.first.attachments["welcome_mailer.csv"])
    end

    it 'interprets the prepare statement' do
      refute_nil(Mail::TestMailer.deliveries.first.attachments["invoice.pdf"])
    end

    it 'adds the attachment to the mail object' do
      refute_nil(Mail::TestMailer.deliveries.first.attachments["render_mailer.html.erb"])
    end

    after do
      Lotus::Mailer.reset!
    end
  end
end
