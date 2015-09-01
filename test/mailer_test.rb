require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do
  before do
    Lotus::Mailer.reset!
  end

  describe '.reset!' do
    before do
      Lotus::Mailer.configure do
        root 'test'
        namespace InvoiceMailer
      end
      Lotus::Mailer.load!
      Lotus::Mailer.reset!
    end
  
    it 'resets root' do
      root = Pathname.new('.').realpath
      Lotus::Mailer.configuration.root.must_equal root
    end

    it "doesn't reset namespace" do
      Lotus::Mailer.configuration.namespace.must_equal(InvoiceMailer)
    end

  end
end
