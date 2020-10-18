# frozen_string_literal: true

require "hanami/mailer/rendering/template_name"
require "hanami/mailer/rendering/templates_finder"

module Hanami
  module Mailer
    # Class level DSL
    #
    # @since 0.1.0
    module Dsl
      # @since 0.3.0
      # @api private
      def self.extended(base)
        base.class_eval do
          @from        = nil
          @to          = nil
          @cc          = nil
          @bcc         = nil
          @reply_to    = nil
          @return_path = nil
          @subject     = nil
        end
      end

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
      # @see Hanami::Mailers::Configuration.root
      #
      # @example Custom template name
      #   require 'hanami/mailer'
      #
      #   class MyMailer
      #     include Hanami::Mailer
      #     template 'mailer'
      #   end
      def template(value = nil)
        if value.nil?
          @template ||= ::Hanami::Mailer::Rendering::TemplateName.new(name, configuration.namespace).to_s
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
          @templates = ::Hanami::Mailer::Rendering::TemplatesFinder.new(self).find
        else
          @templates.fetch(format, nil)
        end
      end

      # Sets the MAIL FROM address for mail messages.
      # This lets you specify a "bounce address" different from the sender
      # address specified with `from`.
      #
      # It accepts a hardcoded value as a string, or a symbol that represents
      # an instance method for more complex logic.
      #
      # This value is optional.
      #
      # When a value is given, specify the MAIL FROM address of the email
      # Otherwise, it returns the MAIL FROM address of the email
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding class variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload return_path(value)
      #   Sets the MAIL FROM address
      #   @param value [String, Symbol] the hardcoded value or method name
      #   @return [NilClass]
      #
      # @overload return_path
      #   Returns the MAIL FROM address
      #   @return [String, Symbol] the MAIL FROM address
      #
      # @since 1.3.2
      #
      # @example Hardcoded value (String)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #
      #     return_path "bounce@example.com"
      #   end
      #
      # @example Method (Symbol)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #     return_path :bounce_address
      #
      #     private
      #
      #     def bounce_address
      #       "bounce@example.com"
      #     end
      #   end
      def return_path(value = nil)
        if value.nil?
          @return_path
        else
          @return_path = value
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
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #
      #     from "noreply@example.com"
      #   end
      #
      # @example Method (Symbol)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
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

      # Sets the cc (carbon copy) for mail messages
      #
      # It accepts a hardcoded value as a string or array of strings.
      # For dynamic values, you can specify a symbol that represents an instance
      # method.
      #
      # This value is optional.
      #
      # When a value is given, it specifies the cc for the email.
      # When a value is not given, it returns the cc of the email.
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding class variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload cc(value)
      #   Sets the cc
      #   @param value [String, Array, Symbol] the hardcoded value or method name
      #   @return [NilClass]
      #
      # @overload cc
      #   Returns the cc
      #   @return [String, Array, Symbol] the recipient
      #
      # @since 0.3.0
      #
      # @example Hardcoded value (String)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #
      #     to "user@example.com"
      #     cc "other.user@example.com"
      #   end
      #
      # @example Hardcoded value (Array)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #
      #     to ["user-1@example.com", "user-2@example.com"]
      #     cc ["other.user-1@example.com", "other.user-2@example.com"]
      #   end
      #
      # @example Method (Symbol)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #     to "user@example.com"
      #     cc :email_address
      #
      #     private
      #
      #     def email_address
      #       user.email
      #     end
      #   end
      #
      #   other_user = User.new(name: 'L')
      #   WelcomeMailer.deliver(user: other_user)
      #
      # @example Method that returns a collection of recipients
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #     to "user@example.com"
      #     cc :recipients
      #
      #     private
      #
      #     def recipients
      #       users.map(&:email)
      #     end
      #   end
      #
      #   other_users = [User.new(name: 'L'), User.new(name: 'MG')]
      #   WelcomeMailer.deliver(users: other_users)
      def cc(value = nil)
        if value.nil?
          @cc
        else
          @cc = value
        end
      end

      # Sets the bcc (blind carbon copy) for mail messages
      #
      # It accepts a hardcoded value as a string or array of strings.
      # For dynamic values, you can specify a symbol that represents an instance
      # method.
      #
      # This value is optional.
      #
      # When a value is given, it specifies the bcc for the email.
      # When a value is not given, it returns the bcc of the email.
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding class variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload bcc(value)
      #   Sets the bcc
      #   @param value [String, Array, Symbol] the hardcoded value or method name
      #   @return [NilClass]
      #
      # @overload bcc
      #   Returns the bcc
      #   @return [String, Array, Symbol] the recipient
      #
      # @since 0.3.0
      #
      # @example Hardcoded value (String)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #
      #     to "user@example.com"
      #     bcc "other.user@example.com"
      #   end
      #
      # @example Hardcoded value (Array)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #
      #     to ["user-1@example.com", "user-2@example.com"]
      #     bcc ["other.user-1@example.com", "other.user-2@example.com"]
      #   end
      #
      # @example Method (Symbol)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #     to "user@example.com"
      #     bcc :email_address
      #
      #     private
      #
      #     def email_address
      #       user.email
      #     end
      #   end
      #
      #   other_user = User.new(name: 'L')
      #   WelcomeMailer.deliver(user: other_user)
      #
      # @example Method that returns a collection of recipients
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #     to "user@example.com"
      #     bcc :recipients
      #
      #     private
      #
      #     def recipients
      #       users.map(&:email)
      #     end
      #   end
      #
      #   other_users = [User.new(name: 'L'), User.new(name: 'MG')]
      #   WelcomeMailer.deliver(users: other_users)
      def bcc(value = nil)
        if value.nil?
          @bcc
        else
          @bcc = value
        end
      end

      # Sets the reply_to for mail messages
      #
      # It accepts a hardcoded value as a string or array of strings.
      # For dynamic values, you can specify a symbol that represents an instance
      # method.
      #
      # This value is optional.
      #
      # When a value is given, it specifies the reply_to for the email.
      # When a value is not given, it returns the reply_to of the email.
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding class variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload reply_to(value)
      #   Sets the reply_to
      #   @param value [String, Array, Symbol] the hardcoded value or method name
      #   @return [NilClass]
      #
      # @overload reply_to
      #   Returns the reply_to
      #   @return [String, Array, Symbol] the recipient
      #
      # @since 1.3.0
      #
      # @example Hardcoded value (String)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #
      #     to "user@example.com"
      #     reply_to "other.user@example.com"
      #   end
      #
      # @example Hardcoded value (Array)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #
      #     to ["user-1@example.com", "user-2@example.com"]
      #     reply_to ["other.user-1@example.com", "other.user-2@example.com"]
      #   end
      #
      # @example Method (Symbol)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #     to "user@example.com"
      #     reply_to :email_address
      #
      #     private
      #
      #     def email_address
      #       user.email
      #     end
      #   end
      #
      #   other_user = User.new(name: 'L')
      #   WelcomeMailer.deliver(user: other_user)
      #
      # @example Method that returns a collection of recipients
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #     to "user@example.com"
      #     reply_to :recipients
      #
      #     private
      #
      #     def recipients
      #       users.map(&:email)
      #     end
      #   end
      #
      #   other_users = [User.new(name: 'L'), User.new(name: 'MG')]
      #   WelcomeMailer.deliver(users: other_users)
      def reply_to(value = nil)
        if value.nil?
          @reply_to
        else
          @reply_to = value
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
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #
      #     to "user@example.com"
      #   end
      #
      # @example Hardcoded value (Array)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #
      #     to ["user-1@example.com", "user-2@example.com"]
      #   end
      #
      # @example Method (Symbol)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
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
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
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
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
      #
      #     subject "Welcome"
      #   end
      #
      # @example Method (Symbol)
      #   require 'hanami/mailer'
      #
      #   class WelcomeMailer
      #     include Hanami::Mailer
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
      # @see Hanami::Mailer.load!
      def load!
        templates.freeze
        configuration.freeze
      end
    end
  end
end
