require 'lotus/mailer/rendering/template_name'
require 'lotus/mailer/rendering/templates_finder'

module Lotus
  module Mailer
    # Class level DSL
    #
    # @since 0.1.0
    module Dsl
      attr_reader :mail
      attr_reader :attachments

      # When a value is given, specify the relative path to the template.
      # Otherwise, it returns the name that follows Lotus::Mailer conventions.
      #
      # @param format [Symbol] template format
      # @param value [String] relative template path
      #
      # @return [Template] the template with the correspondent format for the mailer
      #
      # @since 0.1.0
      #
      # @example Custom template
      #   require 'lotus/mailer'
      #
      #   class MyMailer
      #     include Lotus::Mailer
      #     template :json, 'mailer.json.erb'
      #   end
      #
      #   MyMailer.templates[:json].file  # => 'root/mailer.json.erb'
      def template(format, value)
        @templates[format] = Mailer::Template.new("#{ [configuration.root, value].join('/') }")
      end

      # Returns the Hash with all the templates of the mailer
      #
      # @return [Hash] the Hash with the templates
      #
      # @since 0.1.0
      def templates(value = nil)
        if value.nil?
          # If no templates are given, use the default templates instead
          if @templates.empty?
            @templates = Mailer::Rendering::TemplatesFinder.new(self).find
          else
            @templates
          end
        else
          @templates[value]
        end
      end

      # When a value is given, specify the sender of the email
      # Otherwise, it returns the sender of the email
      #
      # @param value [Object] String or Proc to be evaluated containing the sender of the email
      #
      # @return [String] the sender of the email
      #
      # @since 0.1.0
      #
      # @example With String
      # class StringMailer
      #   include Lotus::Mailer
      #
      #   from "noreply@example.com"
      # end
      #
      # @example With Procs
      # class ProcMailer
      #   include Lotus::Mailer
      #
      #   from -> { customized_sender }
      #
      #   def customized_sender
      #     "user_sender@example.com"
      #   end
      # end
      def from(value = nil)
        if value.nil?
          new.eval_proc(@from)
        else
          @from = value
        end
      end

      # When a value is given, specify the email addresses that will be the recipients of the email
      # Otherwise, it returns the email addresses that will be the recipients of the email
      #
      # @param value [Object] String, Array of Strings or Proc to be evaluated containing the email addresses that will be the recipients of the email
      #
      # @return [String] the email addresses that will be the recipients of the email
      #
      # @since 0.1.0
      #
      # @example With String
      # class StringMailer
      #   include Lotus::Mailer
      #
      #   to "noreply@example.com"
      # end
      #
      # @example With Array of Strings
      # class ArrayMailer
      #   include Lotus::Mailer
      #
      #   to ["noreply1@example.com", "noreply2@example.com"]
      # end
      #
      # @example With Procs
      # class ProcMailer
      #   include Lotus::Mailer
      #
      #   to -> { customized_receiver }
      #
      #   def customized_receiver
      #     "user_receiver@example.com"
      #   end
      # end
      def to(value = nil)
        if value.nil?
          return new.eval_proc(@to)
        end
        if value.is_a?(Array)
          @to = value.join(',')
        else
          @to = value
        end
      end

      # When a value is given, specify the subject of the email
      # Otherwise, it returns the subject of the email
      #
      # @param value [Object] String or Proc to be evaluated containing the subject of the email
      #
      # @return [String] the subject of the email
      #
      # @since 0.1.0
      #
      # @example With String
      # class StringMailer
      #   include Lotus::Mailer
      #
      #   subject "This is the subject"
      # end
      #
      # @example With Procs
      # class ProcMailer
      #   include Lotus::Mailer
      #
      #   subject -> { customized_subject }
      #
      #   def customized_subject
      #     "This is the subject"
      #   end
      # end
      def subject(value = nil)
        if value.nil?
          new.eval_proc(@subject)
        else
          @subject = value
        end
      end

      # Add an attachment to the mail, given the path to file
      #
      # @param path [String or Array of Strings] Filepath(s)
      #
      # @since 0.1.0
      #
      # @example When there is only one attachment
      # class InvoiceMailer
      #   include Lotus::Mailer
      #
      #   attach 'path/to/file/attachment.pdf'
      # end
      #
      # @example When there is an array of paths to attachments
      # class InvoiceMailer
      #   include Lotus::Mailer
      #
      #   attach ['path/to/file/attachment1.pdf','path/to/file/attachment2.pdf']
      # end
      def attach(path)
        if path.is_a? Array
          path.each do |pa|
            name = pa.split('/')[-1]
            @attachments[name] = pa
          end
        else
          name = path.split('/')[-1]
          @attachments[name] = path
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

      attr_writer :mail
      attr_writer :attachments
      attr_writer :templates

    end
  end
end
