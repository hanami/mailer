require 'hanami/utils/class_attribute'
require 'hanami/mailer/version'
require 'hanami/mailer/configuration'
require 'hanami/mailer/dsl'
require 'mail'

# Hanami
#
# @since 0.1.0
module Hanami
  # Hanami::Mailer
  #
  # @since 0.1.0
  module Mailer
    # Base error for Hanami::Mailer
    #
    # @since 0.1.0
    class Error < ::StandardError
    end

    # Missing delivery data error
    #
    # It's raised when a mailer doesn't specify <tt>from</tt> or <tt>to</tt>.
    #
    # @since 0.1.0
    class MissingDeliveryDataError < Error
      def initialize
        super("Missing delivery data, please check 'from', or 'to'")
      end
    end

    # Content types mapping
    #
    # @since 0.1.0
    # @api private
    CONTENT_TYPES = {
      html: 'text/html',
      txt: 'text/plain'
    }.freeze

    include Utils::ClassAttribute

    # @since 0.1.0
    # @api private
    class_attribute :configuration
    self.configuration = Configuration.new

    # Configure the framework.
    # It yields the given block in the context of the configuration
    #
    # @param blk [Proc] the configuration block
    #
    # @since 0.1.0
    #
    # @see Hanami::Mailer::Configuration
    #
    # @example
    #   require 'hanami/mailer'
    #
    #   Hanami::Mailer.configure do
    #     root '/path/to/root'
    #   end
    def self.configure(&blk)
      configuration.instance_eval(&blk)
      self
    end

    # Override Ruby's hook for modules.
    # It includes basic Hanami::Mailer modules to the given Class.
    # It sets a copy of the framework configuration
    #
    # @param base [Class] the target mailer
    #
    # @since 0.1.0
    # @api private
    #
    # @see http://www.ruby-doc.org/core/Module.html#method-i-included
    def self.included(base)
      conf = configuration
      conf.add_mailer(base)

      base.class_eval do
        extend Dsl
        extend ClassMethods

        include Utils::ClassAttribute
        class_attribute :configuration

        self.configuration = conf.duplicate
      end

      conf.copy!(base)
    end

    # Test deliveries
    #
    # This is a collection of delivered messages, used when <tt>delivery_method</tt>
    # is set on <tt>:test</tt>
    #
    # @return [Array] a collection of delivered messages
    #
    # @since 0.1.0
    #
    # @see Hanami::Mailer::Configuration#delivery_mode
    #
    # @example
    #   require 'hanami/mailer'
    #
    #   Hanami::Mailer.configure do
    #     delivery_method :test
    #   end.load!
    #
    #   # In testing code
    #   Signup::Welcome.deliver
    #   Hanami::Mailer.deliveries.count # => 1
    def self.deliveries
      Mail::TestMailer.deliveries
    end

    # Load the framework
    #
    # @since 0.1.0
    # @api private
    def self.load!
      Mail.eager_autoload!
      configuration.load!
    end

    # @since 0.1.0
    module ClassMethods
      # Delivers a multipart email message.
      #
      # When a mailer defines a <tt>html</tt> and <tt>txt</tt> template, they are
      # both delivered.
      #
      # In order to selectively deliver only one of the two templates, use
      # <tt>Signup::Welcome.deliver(format: :txt)</tt>
      #
      # All the given locals, excepted the reserved ones (<tt>:format</tt> and
      # <tt>charset</tt>), are available as rendering context for the templates.
      #
      # @param locals [Hash] a set of objects that acts as context for the rendering
      # @option :format [Symbol] specify format to deliver
      # @option :charset [String] charset
      #
      # @since 0.1.0
      #
      # @see Hanami::Mailer::Configuration#default_charset
      #
      # @example
      #   require 'hanami/mailer'
      #
      #   Hanami::Mailer.configure do
      #     delivery_method :smtp
      #   end.load!
      #
      #   module Billing
      #     class Invoice
      #       include Hanami::Mailer
      #
      #       from    'noreply@example.com'
      #       to      :recipient
      #       subject :subject_line
      #
      #       def prepare
      #         mail.attachments['invoice.pdf'] = File.read('/path/to/invoice.pdf')
      #       end
      #
      #       private
      #
      #       def recipient
      #         user.email
      #       end
      #
      #       def subject_line
      #         "Invoice - #{ invoice.number }"
      #       end
      #     end
      #   end
      #
      #   invoice = Invoice.new
      #   user    = User.new(name: 'L', email: 'user@example.com')
      #
      #   Billing::Invoice.deliver(invoice: invoice, user: user)                      # Deliver both text, HTML parts and the attachment
      #   Billing::Invoice.deliver(invoice: invoice, user: user, format: :txt)        # Deliver only the text part and the attachment
      #   Billing::Invoice.deliver(invoice: invoice, user: user, format: :html)       # Deliver only the text part and the attachment
      #   Billing::Invoice.deliver(invoice: invoice, user: user, charset: 'iso-8859') # Deliver both the parts with "iso-8859"
      def deliver(locals = {})
        new(locals).deliver
      end
    end

    # Initialize a mailer
    #
    # @param locals [Hash] a set of objects that acts as context for the rendering
    # @option :format [Symbol] specify format to deliver
    # @option :charset [String] charset
    #
    # @since 0.1.0
    def initialize(locals = {})
      @locals  = locals
      @format  = locals.fetch(:format, nil)
      @charset = locals.fetch(:charset, self.class.configuration.default_charset)
      @mail    = build
      prepare
    end

    # Render a single template with the specified format.
    #
    # @param format [Symbol] format
    #
    # @return [String] the output of the rendering process.
    #
    # @since 0.1.0
    # @api private
    def render(format)
      self.class.templates(format).render(self, @locals)
    end

    # Delivers a multipart email, by looking at all the associated templates and render them.
    #
    # @since 0.1.0
    # @api private
    def deliver
      mail.deliver
    rescue ArgumentError => exception
      raise MissingDeliveryDataError if exception.message =~ /SMTP (From|To) address/

      raise
    end

    protected

    # Prepare the email message when a new mailer is initialized.
    #
    # This is a hook that can be overwritten by mailers.
    #
    # @since 0.1.0
    #
    # @example
    #   require 'hanami/mailer'
    #
    #   module Billing
    #     class Invoice
    #       include Hanami::Mailer
    #
    #       subject 'Invoice'
    #       from    'noreply@example.com'
    #       to      ''
    #
    #       def prepare
    #         mail.attachments['invoice.pdf'] = File.read('/path/to/invoice.pdf')
    #       end
    #
    #       private
    #
    #       def recipient
    #         user.email
    #       end
    #     end
    #   end
    #
    #   invoice = Invoice.new
    #   user    = User.new(name: 'L', email: 'user@example.com')
    def prepare
    end

    # @api private
    # @since 0.1.0
    def method_missing(method_name)
      @locals.fetch(method_name) { super }
    end

    # @since 0.1.0
    attr_reader :mail

    # @api private
    # @since 0.1.0
    attr_reader :charset

    private

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def build
      Mail.new.tap do |m|
        m.return_path = __dsl(:return_path)
        m.from     = __dsl(:from)
        m.to       = __dsl(:to)
        m.cc       = __dsl(:cc)
        m.bcc      = __dsl(:bcc)
        m.reply_to = __dsl(:reply_to)
        m.subject  = __dsl(:subject)

        m.charset   = charset
        m.html_part = __part(:html)
        m.text_part = __part(:txt)

        m.delivery_method(*Hanami::Mailer.configuration.delivery_method)
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    # @api private
    # @since 0.1.0
    def __dsl(method_name)
      case result = self.class.__send__(method_name)
      when Symbol
        __send__(result)
      else
        result
      end
    end

    # @api private
    # @since 0.1.0
    def __part(format)
      return unless __part?(format)

      Mail::Part.new.tap do |part|
        part.content_type = "#{CONTENT_TYPES.fetch(format)}; charset=#{charset}"
        part.body         = render(format)
      end
    end

    # @api private
    # @since 0.1.0
    def __part?(format)
      @format == format ||
        (!@format && !self.class.templates(format).nil?)
    end

    # @api private
    # @since 0.4.0
    def respond_to_missing?(method_name, _include_all)
      @locals.key?(method_name)
    end
  end
end
