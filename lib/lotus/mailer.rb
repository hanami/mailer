require 'pathname'
require 'lotus/utils/class_attribute'
require 'lotus/mailer/version'
require 'lotus/mailer/configuration'
require 'lotus/mailer/dsl'
require 'lotus/mailer/rendering'
require 'mail'

module Lotus
  module Mailer
    DEFAULT_TEMPLATE = :txt.freeze

    CONTENT_TYPES = {
      html: 'text/html',
      txt:  'text/plain'
    }.freeze

    include Utils::ClassAttribute

    class_attribute :configuration
    self.configuration = Configuration.new

    # Configure the framework.
    # It yields the given block in the context of the configuration
    #
    # @param blk [Proc] the configuration block
    #
    # @since 0.1.0
    #
    # @see Lotus::Mailer::Configuration
    #
    # @example
    #   require 'lotus/mailer'
    #
    #   Lotus::Mailer.configure do
    #     root '/path/to/root'
    #   end
    def self.configure(&blk)
      configuration.instance_eval(&blk)
      self
    end

    # Override Ruby's hook for modules.
    # It includes basic Lotus::Mailer modules to the given Class.
    # It sets a copy of the framework configuration
    #
    # @param base [Class] the target mailer
    #
    # @since 0.1.0
    # @api private
    #
    # @see http://www.ruby-doc.org/core/Module.html#method-i-included
    def self.included(base)
      conf = self.configuration
      conf.add_mailer(base)

      base.class_eval do
        extend Dsl.dup
        extend Rendering.dup
        extend ClassMethods
        include InstanceMethods

        include Utils::ClassAttribute
        class_attribute :configuration

        self.configuration = conf.duplicate
      end

      conf.copy!(base)
    end

    def self.deliveries
      Mail::TestMailer.deliveries
    end

    # Load the framework
    #
    # @since 0.1.0
    # @api private
    def self.load!
      configuration.load!
    end

    module ClassMethods
      # Delivers a multipart email. It instantiates a mailer and deliver the email.
      #
      # @since 0.1.0
      #
      # @example email delivery through smtp via gmail configured with environment variables
      # class DeliveryMethodMailer
      #   include Lotus::Mailer
      #
      #   from ENV["GMAIL_USER"]
      #   to "inesopcoelho@gmail.com"
      #   subject "This is the subject"
      #
      # end
      #
      # MyCustomDeliveryMethod = {
      #   :address              => "smtp.gmail.com",
      #   :port                 => 587,
      #   :domain               => "localhost:8000",
      #   :user_name            => ENV["GMAIL_USER"],
      #   :password             => ENV["GMAIL_PASSWORD"],
      #   :authentication       => "plain",
      #   :enable_starttls_auto => true
      # }
      # Lotus::Mailer.configure do
      #   delivery_method :smtp, MyCustomDeliveryMethod
      # end
      #
      # DeliveryMethodMailer.deliver
      #
      # @example Delivery with locals
      # class User
      #   def initialize(name)
      #     @name = name
      #   end
      #
      #   attr_reader :name
      # end
      #
      # luca = User.new('Luca')
      # Lotus::Mailer.load!
      # InvoiceMailer.deliver(user: luca)
      def deliver(locals = {})
        new(locals).deliver
      end
    end

    module InstanceMethods
      # Delivers a multipart email, by looking at all the associated templates and render them.
      #
      # @since 0.1.0
      def deliver
        mail.deliver
      end
    end

    protected

    def method_missing(m)
      @locals.fetch(m) { super }
    end

    protected

    attr_reader :charset

    private

    def __dsl(method_name)
      case result = self.class.__send__(method_name)
      when Symbol
        __send__(result)
      else
        result
      end
    end

    def __part(format)
      Mail::Part.new.tap do |part|
        part.content_type = "#{ CONTENT_TYPES.fetch(format) }; charset=#{ charset }"
        part.body         = render(format)
      end if __part?(format)
    end

    def __part?(format)
      @format == format ||
        (!@format && !self.class.templates(format).nil?)
    end
  end
end
