require 'set'
require 'hanami/utils/kernel'

module Hanami
  module Mailer
    # Framework configuration
    #
    # @since 0.1.0
    class Configuration
      # Default root
      #
      # @since 0.1.0
      # @api private
      DEFAULT_ROOT = '.'.freeze

      # Default delivery method
      #
      # @since 0.1.0
      # @api private
      DEFAULT_DELIVERY_METHOD = :smtp

      # Default charset
      #
      # @since 0.1.0
      # @api private
      DEFAULT_CHARSET = 'UTF-8'.freeze

      # @since 0.1.0
      # @api private
      attr_reader :mailers

      # @since 0.1.0
      # @api private
      attr_reader :modules

      # Initialize a configuration instance
      #
      # @return [Hanami::Mailer::Configuration] a new configuration's instance
      #
      # @since 0.1.0
      def initialize
        @namespace = Object
        reset!
      end

      # Set the Ruby namespace where to lookup for mailers.
      #
      # When multiple instances of the framework are used, we want to make sure
      # that if a `MyApp` wants a `Mailers::Signup` mailer, we are loading the
      # right one.
      #
      # If not set, this value defaults to `Object`.
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding instance variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload namespace(value)
      #   Sets the given value
      #   @param value [Class, Module, String] a valid Ruby namespace identifier
      #
      # @overload namespace
      #   Gets the value
      #   @return [Class, Module, String]
      #
      # @api private
      # @since 0.1.0
      #
      # @example Getting the value
      #   require 'hanami/mailer'
      #
      #   Hanami::Mailer.configuration.namespace # => Object
      #
      # @example Setting the value
      #   require 'hanami/mailer'
      #
      #   Hanami::Mailer.configure do
      #     namespace 'MyApp::Mailers'
      #   end
      def namespace(value = nil)
        if value
          @namespace = value
        else
          @namespace
        end
      end

      # Set the root path where to search for templates
      #
      # If not set, this value defaults to the current directory.
      #
      # When this method is called with an argument, it will set the corresponding instance variable.
      # When called without, it will return the already set value, or the default.
      #
      # @overload root(value)
      #   Sets the given value
      #   @param value [String, Pathname, #to_pathname] an object that can be
      #     coerced to Pathname
      #
      # @overload root
      #   Gets the value
      #   @return [Pathname]
      #
      # @since 0.1.0
      #
      # @see http://www.ruby-doc.org/stdlib/libdoc/pathname/rdoc/Pathname.html
      # @see http://rdoc.info/gems/hanami-utils/Hanami/Utils/Kernel#Pathname-class_method
      #
      # @example Getting the value
      #   require 'hanami/mailer'
      #
      #   Hanami::Mailer.configuration.root # => #<Pathname:.>
      #
      # @example Setting the value
      #   require 'hanami/mailer'
      #
      #   Hanami::Mailer.configure do
      #     root '/path/to/templates'
      #   end
      #
      #   Hanami::Mailer.configuration.root # => #<Pathname:/path/to/templates>
      def root(value = nil)
        if value
          @root = Utils::Kernel.Pathname(value).realpath
        else
          @root
        end
      end

      # Prepare the mailers.
      #
      # The given block will be yielded when `Hanami::Mailer` will be included by
      # a mailer.
      #
      # This method can be called multiple times.
      #
      # @param blk [Proc] the code block
      #
      # @return [void]
      #
      # @raise [ArgumentError] if called without passing a block
      #
      # @since 0.1.0
      #
      # @see Hanami::Mailer.configure
      def prepare(&blk)
        if block_given? # rubocop:disable Style/GuardClause
          @modules.push(blk)
        else
          raise ArgumentError.new('Please provide a block')
        end
      end

      # Add a mailer to the registry
      #
      # @since 0.1.0
      # @api private
      def add_mailer(mailer)
        @mailers.add(mailer)
      end

      # Duplicate by copying the settings in a new instance.
      #
      # @return [Hanami::Mailer::Configuration] a copy of the configuration
      #
      # @since 0.1.0
      # @api private
      def duplicate
        Configuration.new.tap do |c|
          c.namespace  = namespace
          c.root       = root.dup
          c.modules    = modules.dup
          c.delivery_method = delivery_method
          c.default_charset = default_charset
        end
      end

      # Load the configuration
      def load!
        mailers.each { |m| m.__send__(:load!) }
        freeze
      end

      # Reset the configuration
      def reset!
        root(DEFAULT_ROOT)
        delivery_method(DEFAULT_DELIVERY_METHOD)
        default_charset(DEFAULT_CHARSET)

        @mailers = Set.new
        @modules = []
      end

      alias unload! reset!

      # Copy the configuration for the given mailer
      #
      # @param base [Class] the target mailer
      #
      # @return void
      #
      # @since 0.1.0
      # @api private
      def copy!(base)
        modules.each do |mod|
          base.class_eval(&mod)
        end
      end

      # Specify a global delivery method for the mail gateway.
      #
      # It supports the following delivery methods:
      #
      #   * Exim (<tt>:exim</tt>)
      #   * Sendmail (<tt>:sendmail</tt>)
      #   * SMTP (<tt>:smtp</tt>, for local installations)
      #   * SMTP Connection (<tt>:smtp_connection</tt>,
      #     via <tt>Net::SMTP</tt> - for remote installations)
      #   * Test (<tt>:test</tt>, for testing purposes)
      #
      # The default delivery method is SMTP (<tt>:smtp</tt>).
      #
      # Custom delivery methods can be specified by passing the class policy and
      # a set of optional configurations. This class MUST respond to:
      #
      #   * <tt>initialize(options = {})</tt>
      #   * <tt>deliver!(mail)<tt>
      #
      # @param method [Symbol, #initialize, deliver!] delivery method
      # @param options [Hash] optional settings
      #
      # @return [Array] an array containing the delivery method and the optional settings as an Hash
      #
      # @since 0.1.0
      #
      # @example Setup delivery method with supported symbol
      #   require 'hanami/mailer'
      #
      #   Hanami::Mailer.configure do
      #     delivery_method :sendmail
      #   end
      #
      # @example Setup delivery method with supported symbol and options
      #   require 'hanami/mailer'
      #
      #   Hanami::Mailer.configure do
      #     delivery_method :smtp, address: "localhost", port: 1025
      #   end
      #
      # @example Setup custom delivery method with options
      #   require 'hanami/mailer'
      #
      #   class MandrillDeliveryMethod
      #     def initialize(options)
      #       @options = options
      #     end
      #
      #     def deliver!(mail)
      #       # ...
      #     end
      #   end
      #
      #   Hanami::Mailer.configure do
      #     delivery_method MandrillDeliveryMethod,
      #       username: ENV['MANDRILL_USERNAME'],
      #       password: ENV['MANDRILL_API_KEY']
      #   end
      def delivery_method(method = nil, options = {})
        if method.nil?
          @delivery_method
        else
          @delivery_method = [method, options]
        end
      end

      # @since 0.1.0
      def default_charset(value = nil)
        if value.nil?
          @default_charset
        else
          @default_charset = value
        end
      end

      protected

      # @api private
      # @since 0.1.0
      attr_writer :root

      # @api private
      # @since 0.1.0
      attr_writer :delivery_method

      # @api private
      # @since 0.1.0
      attr_writer :default_charset

      # @api private
      # @since 0.1.0
      attr_writer :namespace

      # @api private
      # @since 0.1.0
      attr_writer :modules
    end
  end
end
