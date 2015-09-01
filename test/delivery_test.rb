describe Lotus::Mailer do
  describe '#deliver' do
    before do
      Lotus::Mailer.configure do
        delivery_method :test
      end
      Lotus::Mailer.load!
      Mail::TestMailer.deliveries.clear
      WelcomeMailer.deliver
      SubscriptionMailer.deliver
    end

    it 'delivers the mail' do
      Mail::TestMailer.deliveries.length.must_equal 2
    end

    it 'sends the correct information' do
      Mail::TestMailer.deliveries.first.from.must_equal ['noreply@sender.com']
      Mail::TestMailer.deliveries.first.to.must_equal ['noreply@recipient.com']
      Mail::TestMailer.deliveries.first.subject.must_equal "Welcome"
    end

    it 'has the correct templates' do
      Mail::TestMailer.deliveries.first.html_part.to_s.must_include %(template)
      Mail::TestMailer.deliveries.first.text_part.to_s.must_include %(template)
      Mail::TestMailer.deliveries.first.attachments[0].to_s.must_include %(welcome_mailer)
      Mail::TestMailer.deliveries.first.attachments[1].to_s.must_include %(welcome_mailer)
    end

    it 'interprets the prepare statement' do
      Mail::TestMailer.deliveries[1].attachments[0].to_s.must_include %(pdf)
    end

    after do
      Lotus::Mailer.reset!
      Lotus::Mailer.configure do
        delivery_method :smtp
      end
    end
  end
end
