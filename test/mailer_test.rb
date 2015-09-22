require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do
  describe '.configure' do
    before do
      Lotus::Mailer.reset!
    end

    after do
      Lotus::Mailer.reset!
    end

    it 'configures the framework' do
      Lotus::Mailer.configure do
        root __dir__
      end

      Lotus::Mailer.configuration.root.must_equal Pathname.new(__dir__)
    end

    it 'allows chained calls' do
      Lotus::Mailer.configure do
      end.load!
    end
  end

  describe '.load!' do
    describe 'when custom template is set' do
      before do
        InvoiceMailer.reset!
        Lotus::Mailer.reset!
        InvoiceMailer.template('welcome_mailer.csv.erb')

        Lotus::Mailer.load!
      end

      after do
        Lotus::Mailer.reset!
      end

      it 'will look up template' do
        template_test = InvoiceMailer.templates(:csv)
        template_test.must_be_kind_of(Lotus::Mailer::Template)
      end
    end
  end

  describe '.duplicate' do
    before do
      Lotus::Mailer.configure do
        root 'test'
      end
      module Duplicated
        Mailer = Lotus::Mailer.duplicate(self)
      end

      module DuplicatedConfigure
        Mailer = Lotus::Mailer.duplicate(self) do
          root 'test/fixtures'
        end
      end
    end

    it 'duplicates the configuration of the framework' do
      actual = Duplicated::Mailer.configuration
      actual.root.must_equal Lotus::Mailer.configuration.root
    end

    it 'optionally accepts a block to configure the duplicated module' do
      configuration = DuplicatedConfigure::Mailer.configuration

      configuration.root.must_equal(Pathname.new('test/fixtures').realpath)
      configuration.root.wont_equal(Pathname.new('test').realpath)
    end

    after do
      Lotus::Mailer.configuration.reset!

      Object.send(:remove_const, :Duplicated)
      Object.send(:remove_const, :DuplicatedConfigure)
    end
  end
end
