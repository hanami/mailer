# frozen_string_literal: true

RSpec.describe Hanami::Mailer::Configuration do
  before do
    @configuration = Hanami::Mailer::Configuration.new
  end

  describe "#root" do
    describe "when a value is given" do
      describe "and it is a string" do
        it "sets it as a Pathname" do
          @configuration.root "spec"
          expect(@configuration.root).to eq(Pathname.new("spec").realpath)
        end
      end

      describe "and it is a pathname" do
        it "sets it" do
          @configuration.root Pathname.new("spec")
          expect(@configuration.root).to eq(Pathname.new("spec").realpath)
        end
      end

      describe "and it implements #to_pathname" do
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

        it "sets the converted value" do
          @configuration.root RootPath.new("spec")
          expect(@configuration.root).to eq(Pathname.new("spec").realpath)
        end
      end

      describe "and it is an unexisting path" do
        it "raises an error" do
          expect do
            @configuration.root "/path/to/unknown"
          end.to raise_error(Errno::ENOENT)
        end
      end
    end

    describe "when a value is not given" do
      it "defaults to the current path" do
        expect(@configuration.root).to eq(Pathname.new(".").realpath)
      end
    end
  end

  describe "#mailers" do
    it "defaults to an empty set" do
      expect(@configuration.mailers).to be_empty
    end

    it "allows to add mailers" do
      @configuration.add_mailer(InvoiceMailer)
      expect(@configuration.mailers).to include(InvoiceMailer)
    end

    it "eliminates duplications" do
      @configuration.add_mailer(RenderMailer)
      @configuration.add_mailer(RenderMailer)

      expect(@configuration.mailers.size).to eq(1)
    end
  end

  describe "#prepare" do
    before do
      module FooRendering
        def render
          "foo"
        end
      end

      class PrepareMailer
      end
    end

    after do
      Object.__send__(:remove_const, :FooRendering)
      Object.__send__(:remove_const, :PrepareMailer)
    end

    it "raises error in case of missing block" do
      expect { @configuration.prepare }.to raise_error(ArgumentError, "Please provide a block")
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

  describe "#load!" do
    before do
      @configuration.root "spec"
      @configuration.load!
    end

    it "loads root" do
      root = Pathname.new("spec").realpath
      expect(@configuration.root).to eq(root)
    end
  end

  describe "#delivery_method" do
    describe "when not previously set" do
      before do
        @configuration.reset!
      end

      it "defaults to SMTP" do
        expect(@configuration.delivery_method).to eq([:smtp, {}])
      end
    end

    describe "set with a symbol" do
      before do
        @configuration.delivery_method :exim, location: "/path/to/exim"
      end

      it "saves the delivery method in the configuration" do
        expect(@configuration.delivery_method).to eq([:exim, { location: "/path/to/exim" }])
      end
    end

    describe "set with a class" do
      before do
        @configuration.delivery_method MandrillDeliveryMethod,
                                       username: "mandrill-username", password: "mandrill-api-key"
      end

      it "saves the delivery method in the configuration" do
        expect(@configuration.delivery_method).to eq([MandrillDeliveryMethod, username: "mandrill-username", password: "mandrill-api-key"])
      end
    end
  end

  describe "#default_charset" do
    describe "when not previously set" do
      before do
        @configuration.reset!
      end

      it "defaults to UTF-8" do
        expect(@configuration.default_charset).to eq("UTF-8")
      end
    end

    describe "when set" do
      before do
        @configuration.default_charset "iso-8859-1"
      end

      it "saves the delivery method in the configuration" do
        expect(@configuration.default_charset).to eq("iso-8859-1")
      end
    end
  end

  describe "#prepare" do
    it "injects code in each mailer"
    # it 'injects code in each mailer' do
    #   InvoiceMailer.subject.must_equal 'default subject'
    # end
  end
end
