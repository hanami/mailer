require 'pathname'
require 'lotus/utils/class_attribute'
require 'lotus/mailer/version'
require 'lotus/mailer/configuration'
require 'lotus/mailer/dsl'
require 'lotus/mailer/rendering'
require 'mail'

module Lotus
  module Mailer
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
        self.templates(Hash.new)
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
      def deliver(locals = {}, template: :text)
        new(locals).deliver(template)
      end
    end

    module InstanceMethods
      # Delivers a multipart email, by looking at all the associated templates and render them.
      #
      # @since 0.1.0
      def deliver (template)
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
            #puts render(type)
            mail.attachments[content.name] = render(type)
          end
        end

        if self.respond_to? ('prepare')
          self.prepare
        end

        mail.deliver
      end
    end
  end
end
