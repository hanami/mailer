require 'lotus/mailer/rendering/template_name'
require 'lotus/mailer/rendering/templates_finder'

module Lotus
  module Mailer
    # Class level DSL
    #
    # @since 0.1.0
    module Dsl
      # Set the template name IF it differs from the convention.
      #
      # For a given mailer named <tt>Signup::Welcome</tt> it will look for
      # <tt>signup/welcome.*.*</tt> templates under the root directory.
      #
      # If for some reason, we need to specify a different template name, we can
      # use this method.
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding class variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload template(value)
      #   Sets the given value
      #   @param value [String, #to_s] relative template path, under root
      #   @return [NilClass]
      #
      # @overload template
      #   Gets the template name
      #   @return [String]
      #
      # @since 0.1.0
      #
      # @see Lotus::Mailers::Configuration.root
      #
      # @example Custom template name
      #   require 'lotus/mailer'
      #
      #   class MyMailer
      #     include Lotus::Mailer
      #     template 'mailer'
      #   end
      def template(value = nil)
        if value.nil?
          @template ||= ::Lotus::Mailer::Rendering::TemplateName.new(name, configuration.namespace).to_s
        else
          @template = value
        end
      end

      # Returns a set of associated templates or only one for the given format
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding class variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload templates(format)
      #   Returns the template associated with the given format
      #   @param value [Symbol] the format
      #   @return [Hash]
      #
      # @overload templates
      #   Returns all the associated templates
      #   Gets the template name
      #   @return [Hash] a set of templates
      #
      # @since 0.1.0
      # @api private
      def templates(format = nil)
        if format.nil?
          @templates = ::Lotus::Mailer::Rendering::TemplatesFinder.new(self).find
        else
          @templates.fetch(format, nil)
        end
      end

      # Sets the sender for mail messages
      #
      # It accepts a hardcoded value as a string, or a symbol that represents
      # an instance method for more complex logic.
      #
      # This value MUST be set, otherwise an exception is raised at the delivery
      # time.
      #
      # When a value is given, specify the sender of the email
      # Otherwise, it returns the sender of the email
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding class variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload from(value)
      #   Sets the sender
      #   @param value [String, Symbol] the hardcoded value or method name
      #   @return [NilClass]
      #
      # @overload from
      #   Returns the sender
      #   @return [String, Symbol] the sender
      #
      # @since 0.1.0
      #
      # @example Hardcoded value (String)
      #   require 'lotus/mailer'
      #
      #   class WelcomeMailer
      #     include Lotus::Mailer
      #
      #     from "noreply@example.com"
      #   end
      #
      # @example Method (Symbol)
      #   require 'lotus/mailer'
      #
      #   class WelcomeMailer
      #     include Lotus::Mailer
      #     from :sender
      #
      #     private
      #
      #     def sender
      #       "noreply@example.com"
      #     end
      #   end
      def from(value = nil)
        if value.nil?
          @from
        else
          @from = value
        end
      end

      # Sets the recipient for mail messages
      #
      # It accepts a hardcoded value as a string or array of strings.
      # For dynamic values, you can specify a symbol that represents an instance
      # method.
      #
      # This value MUST be set, otherwise an exception is raised at the delivery
      # time.
      #
      # When a value is given, specify the recipient of the email
      # Otherwise, it returns the recipient of the email
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding class variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload to(value)
      #   Sets the recipient
      #   @param value [String, Array, Symbol] the hardcoded value or method name
      #   @return [NilClass]
      #
      # @overload to
      #   Returns the recipient
      #   @return [String, Array, Symbol] the recipient
      #
      # @since 0.1.0
      #
      # @example Hardcoded value (String)
      #   require 'lotus/mailer'
      #
      #   class WelcomeMailer
      #     include Lotus::Mailer
      #
      #     to "user@example.com"
      #   end
      #
      # @example Hardcoded value (Array)
      #   require 'lotus/mailer'
      #
      #   class WelcomeMailer
      #     include Lotus::Mailer
      #
      #     to ["user-1@example.com", "user-2@example.com"]
      #   end
      #
      # @example Method (Symbol)
      #   require 'lotus/mailer'
      #
      #   class WelcomeMailer
      #     include Lotus::Mailer
      #     to :email_address
      #
      #     private
      #
      #     def email_address
      #       user.email
      #     end
      #   end
      #
      #   user = User.new(name: 'L')
      #   WelcomeMailer.deliver(user: user)
      #
      # @example Method that returns a collection of recipients
      #   require 'lotus/mailer'
      #
      #   class WelcomeMailer
      #     include Lotus::Mailer
      #     to :recipients
      #
      #     private
      #
      #     def recipients
      #       users.map(&:email)
      #     end
      #   end
      #
      #   users = [User.new(name: 'L'), User.new(name: 'MG')]
      #   WelcomeMailer.deliver(users: users)
      def to(value = nil)
        if value.nil?
          @to
        else
          @to = value
        end
      end

      # Sets the subject for mail messages
      #
      # It accepts a hardcoded value as a string, or a symbol that represents
      # an instance method for more complex logic.
      #
      # This value MUST be set, otherwise an exception is raised at the delivery
      # time.
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding class variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload subject(value)
      #   Sets the subject
      #   @param value [String, Symbol] the hardcoded value or method name
      #   @return [NilClass]
      #
      # @overload subject
      #   Returns the subject
      #   @return [String, Symbol] the subject
      #
      # @since 0.1.0
      #
      # @example Hardcoded value (String)
      #   require 'lotus/mailer'
      #
      #   class WelcomeMailer
      #     include Lotus::Mailer
      #
      #     subject "Welcome"
      #   end
      #
      # @example Method (Symbol)
      #   require 'lotus/mailer'
      #
      #   class WelcomeMailer
      #     include Lotus::Mailer
      #     subject :greeting
      #
      #     private
      #
      #     def greeting
      #       "Hello, #{ user.name }"
      #     end
      #   end
      #
      #   user = User.new(name: 'L')
      #   WelcomeMailer.deliver(user: user)
      def subject(value = nil)
        if value.nil?
          @subject
        else
          @subject = value
        end
      end

      protected

      # Loading mechanism hook.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Mailer.load!
      def load!
        templates.freeze
        configuration.freeze
      end
    end
  end
end
