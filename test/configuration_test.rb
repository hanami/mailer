require 'test_helper'

describe Lotus::Mailer::Configuration do
  before do
    @configuration = Lotus::Mailer::Configuration.new
  end

  describe '#root' do
    describe 'when a value is given' do
      describe 'and it is a string' do
        it 'sets it as a Pathname' do
          @configuration.root 'test'
          @configuration.root.must_equal(Pathname.new('test').realpath)
        end
      end

      describe 'and it is a pathname' do
        it 'sets it' do
          @configuration.root Pathname.new('test')
          @configuration.root.must_equal(Pathname.new('test').realpath)
        end
      end

      describe 'and it implements #to_pathname' do
        before do
          RootPath = Struct.new(:path) do
            def to_pathname
              Pathname(path)
            end
          end
        end

        after do
          Object.send(:remove_const, :RootPath)
        end

        it 'sets the converted value' do
          @configuration.root RootPath.new('test')
          @configuration.root.must_equal(Pathname.new('test').realpath)
        end
      end

      describe 'and it is an unexisting path' do
        it 'raises an error' do
          -> {
            @configuration.root '/path/to/unknown'
          }.must_raise(Errno::ENOENT)
        end
      end
    end

    describe 'when a value is not given' do
      it 'defaults to the current path' do
        @configuration.root.must_equal(Pathname.new('.').realpath)
      end
    end
  end

  describe '#mailers' do
    it 'defaults to an empty set' do
      @configuration.mailers.must_be_empty
    end

    it 'allows to add mailers' do
      @configuration.add_mailer(InvoiceMailer)
      @configuration.mailers.must_include(InvoiceMailer)
    end

    it 'eliminates duplications' do
      @configuration.add_mailer(RenderMailer)
      @configuration.add_mailer(RenderMailer)

      @configuration.mailers.size.must_equal(1)
    end
  end

  describe '#prepare' do
    before do
      module FooRendering
        def render
          'foo'
        end
      end

      class PrepareMailer
      end
    end

    after do
      Object.__send__(:remove_const, :FooRendering)
      Object.__send__(:remove_const, :PrepareMailer)
    end

    it 'raises error in case of missing block' do
      exception = -> { @configuration.prepare }.must_raise(ArgumentError)
      exception.message.must_equal('Please provide a block')
    end
  end

  describe '#duplicate' do
    before do
      @configuration.root 'test'
      @configuration.add_mailer( InvoiceMailer )
      @configuration.prepare { include Kernel }

      @config = @configuration.duplicate
    end

    it 'returns a copy of the configuration' do
      @config.root.must_equal       @configuration.root
      @config.modules.must_equal    @configuration.modules
      @config.mailers.must_be_empty
    end

    it "doesn't affect the original configuration" do
      @config.root '.'
      @config.add_mailer(RenderMailer)
      @config.prepare { include Comparable }

      @config.root.must_equal         Pathname.new('.').realpath
      @config.mailers.must_include      RenderMailer
      @config.modules.size.must_equal 2

      @configuration.root.must_equal       Pathname.new('test').realpath
      @configuration.mailers.must_include    InvoiceMailer
      @configuration.mailers.wont_include    RenderMailer
    end

    it 'duplicates namespace' do
      @configuration.namespace(InvoiceMailer)
      conf = @configuration.duplicate

      conf.namespace.must_equal(InvoiceMailer)
    end
  end

  # describe '#reset!' do
  #   before do
  #     @configuration.root 'test'
  #     @configuration.add_mailer(InvoiceMailer)

  #     @configuration.reset!
  #   end

  #   it 'resets root' do
  #     root = Pathname.new('.').realpath

  #     @configuration.root.must_equal root
  #     @configuration.mailers.must_be_empty
  #   end

  #   it "doesn't reset namespace" do
  #     @configuration.namespace(InvoiceMailer)
  #     @configuration.reset!

  #     @configuration.namespace.must_equal(InvoiceMailer)
  #   end

  # end

  describe '#load!' do
    before do
      @configuration.root 'test'
      @configuration.load!
    end

    it 'loads root' do
      root = Pathname.new('test').realpath
      @configuration.root.must_equal root
    end
  end

  describe '#delivery_method' do
    describe 'when not previously set' do
      before do
        @configuration.reset!
      end

      it 'defaults to SMTP' do
        @configuration.delivery_method.must_equal [:smtp, {}]
      end
    end

    describe 'set with a symbol' do
      before do
        @configuration.delivery_method :exim, location: '/path/to/exim'
      end

      it 'saves the delivery method in the configuration' do
        @configuration.delivery_method.must_equal [:exim, { location: '/path/to/exim' }]
      end
    end

    describe 'set with a class' do
      before do
        @configuration.delivery_method MandrillDeliveryMethod,
          username: 'mandrill-username', password: 'mandrill-api-key'
      end

      it 'saves the delivery method in the configuration' do
        @configuration.delivery_method.must_equal [MandrillDeliveryMethod,
                                                   username: 'mandrill-username', password: 'mandrill-api-key']
      end
    end
  end

  describe '#delivery' do
    describe 'when not previously set' do
      before do
        @configuration.reset!
      end

      it 'defaults to SMTP' do
        @configuration.delivery.must_equal [:smtp, {}]
      end
    end

    describe 'set with a symbol' do
      before do
        @configuration.delivery :exim, location: '/path/to/exim'
      end

      it 'saves the delivery method in the configuration' do
        @configuration.delivery.must_equal [:exim, { location: '/path/to/exim' }]
      end
    end

    describe 'set with a class' do
      before do
        @configuration.delivery MandrillDeliveryMethod,
          username: 'mandrill-username', password: 'mandrill-api-key'
      end

      it 'saves the delivery method in the configuration' do
        @configuration.delivery.must_equal [MandrillDeliveryMethod,
                                            username: 'mandrill-username', password: 'mandrill-api-key']
      end
    end
  end

  describe '#default_charset' do
    describe 'when not previously set' do
      before do
        @configuration.reset!
      end

      it 'defaults to UTF-8' do
        @configuration.default_charset.must_equal 'UTF-8'
      end
    end

    describe 'when set' do
      before do
        @configuration.default_charset 'iso-8859-1'
      end

      it 'saves the delivery method in the configuration' do
        @configuration.default_charset.must_equal 'iso-8859-1'
      end
    end
  end
end
