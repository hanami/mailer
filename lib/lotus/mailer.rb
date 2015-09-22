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
    # @see http://www.ruby-doc.org/core-2.1.2/Module.html#method-i-included
    #
    # @example
    #   require 'lotus/mailer'
    #
    #   class IndexMailer
    #     include Lotus::Mailer
    #   end
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
        self.templates = Hash.new
        self.attachments = Hash.new
      end

      conf.copy!(base)
    end

    # Evaluate Proc
    # It evaluates an object, and if it is a Proc executes it
    #
    # param var [Object] the object to be evaluated
    #
    # @since 0.1.0
    # @api private
    def eval_proc(var)
      if var.is_a?(Proc)
        instance_exec(&var)
      else
        var
      end
    end

    # Load the framework
    #
    # @since 0.1.0
    # @api private
    def self.load!
      configuration.load!
    end

    # Duplicate Lotus::Mailer in order to create a new separated instance
    # of the framework.
    #
    # The new instance of the framework will be completely decoupled from the
    # original. It will inherit the configuration, but all the changes that
    # happen after the duplication, won't be reflected on the other copies.
    #
    # @return [Module] a copy of Lotus::Mailer
    #
    # @since 0.1.0
    # @api private
    #
    # @example Basic usage
    #   require 'lotus/mailer'
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.dupe
    #   end
    #
    #   MyApp::Mailer == Lotus::Mailer # => false
    #
    #   MyApp::Mailer.configuration ==
    #     Lotus::Mailer.configuration # => false
    #
    # @example Inheriting configuration
    #   require 'lotus/mailer'
    #
    #   Lotus::Mailer.configure do
    #     root '/path/to/root'
    #   end
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.dupe
    #   end
    #
    #   module MyApi
    #     Mailer = Lotus::Mailer.dupe
    #     Mailer.configure do
    #       root '/another/root'
    #     end
    #   end
    #
    #   Lotus::Mailer.configuration.root # => #<Pathname:/path/to/root>
    #   MyApp::Mailer.configuration.root # => #<Pathname:/path/to/root>
    #   MyApi::Mailer.configuration.root # => #<Pathname:/another/root>
    def self.dupe
      dup.tap do |duplicated|
        duplicated.configuration = configuration.duplicate
      end
    end

    # Duplicate the framework and generate modules for the target application
    #
    # @param mod [Module] the Ruby namespace of the application
    # @param mailers [String] the optional namespace where the application's
    #   mailers will live
    # @param blk [Proc] an optional block to configure the framework
    #
    # @return [Module] a copy of Lotus::Mailer
    #
    # @since 0.1.0
    #
    # @see Lotus::Mailer#dupe
    # @see Lotus::Mailer::Configuration
    # @see Lotus::Mailer::Configuration#namespace
    #
    # @example Basic usage
    #   require 'lotus/mailer'
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.duplicate(self)
    #   end
    #
    #  module MyApp::Mailers::InvoiceMailer
    #    class Index
    #      include MyApp::Mailer
    #    end
    #  end
    #
    # @example Compare code
    #   require 'lotus/mailer'
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.duplicate(self) do
    #       # ...
    #     end
    #   end
    #
    #   # it's equivalent to:
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.dupe
    #
    #     module Mailers
    #     end
    #
    #     Mailer.configure do
    #       namespace 'MyApp::Mailers'
    #     end
    #
    #     Mailer.configure do
    #       # ...
    #     end
    #   end
    #
    # @example Custom mailers module
    #   require 'lotus/mailer
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.duplicate(self, 'Vs')
    #   end
    #
    #   defined?(MyApp::Mailers) # => nil
    #   defined?(MyApp::Vs)      # => "constant"
    #
    #   # Developers can namespace mailers under Vs
    #   module MyApp::Vs::InvoiceMailer
    #     # ...
    #   end
    #
    # @example Nil mailers module
    #   require 'lotus/mailer'
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.duplicate(self, nil)
    #   end
    #
    #   defined?(MyApp::Mailers) # => nil
    #
    #   # Developers can namespace mailers under MyApp
    #   module MyApp
    #     # ...
    #   end
    #
    # @example Block usage
    #   require 'lotus/mailer'
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.duplicate(self) do
    #       root '/path/to/root'
    #     end
    #   end
    #
    #   Lotus::Mailer.configuration.root # => #<Pathname:.>
    #   MyApp::Mailer.configuration.root # => #<Pathname:/path/to/root>
    def self.duplicate(mod, mailers = 'Mailers', &blk)
      dupe.tap do |duplicated|
        mod.module_eval %{ module #{ mailers }; end } if mailers

        duplicated.configure do
          namespace [mod, mailers].compact.join '::'
        end

        duplicated.configure(&blk) if block_given?
      end
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
      # InvoiceMailer.deliver(locals: {user:luca})
      def deliver(locals: {}, template: DEFAULT_TEMPLATE)
        new(locals).deliver(template)
      end
    end

    module InstanceMethods
      # Delivers a multipart email, by looking at all the associated templates and render them.
      #
      # @since 0.1.0
      def deliver(template)
        mail['from'] = self.class.from
        mail['to'] = self.class.to
        mail['subject'] = self.class.subject
        if Lotus::Mailer.configuration.delivery_method
          mail.delivery_method *Lotus::Mailer.configuration.delivery_method
        end

        #attach templates
        self.class.templates.each do |type, content|
          case type
          when :html
            mail_body = Mail::Part.new
            mail_body.content_type 'text/html; charset=UTF-8'
            mail_body.body render(:html)
            mail.html_part = mail_body
          when :txt
            mail_body = Mail::Part.new
            mail_body.body render(:txt)
            mail.text_part = mail_body
          else
            mail.attachments[content.name] = render(type)
          end
        end

        self.class.attachments.each do |name, path|
          mail.attachments[name] = path
        end

        if self.respond_to? ('prepare')
          self.prepare
        end

        mail.deliver
      end
    end
  end
end
