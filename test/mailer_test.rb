require 'test_helper'
require 'lotus/mailer'

describe Lotus::Mailer do
  describe '.load!' do
    describe 'when custom template is set' do
      before do
        InvoiceMailer.reset!
        Lotus::Mailer.reset!
        InvoiceMailer.template(:csv, 'welcome_mailer.csv.erb')
        Lotus::Mailer.load!
      end
      it 'will look up template' do
        template_test = InvoiceMailer.templates[:csv]
        template_test.must_be_kind_of(Lotus::Mailer::Template)
      end
      after do
        Lotus::Mailer.reset!
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
