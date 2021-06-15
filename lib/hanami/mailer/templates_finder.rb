# frozen_string_literal: true

require "hanami/mailer/template"
require "hanami/utils/file_list"
require "pathname"

module Hanami
  class Mailer
    # Find templates for a mailer
    #
    # @api private
    # @since 0.1.0
    #
    # @see Mailer::Template
    class TemplatesFinder
      # Default format
      #
      # @api private
      # @since 0.1.0
      FORMAT    = "*"

      # Default template engines
      #
      # @api private
      # @since 0.1.0
      ENGINES   = "*"

      # Recursive pattern
      #
      # @api private
      # @since 0.1.0
      RECURSIVE = "**"

      # Format separator
      #
      # @api unstable
      # @since next
      #
      # @example
      #   welcome.html.erb
      FORMAT_SEPARATOR = "."

      private_constant(*constants(true))

      # Initialize a finder
      #
      # @param root [String,Pathname] the root directory where to recursively
      #   look for templates
      #
      # @raise [Errno::ENOENT] if the directory doesn't exist
      #
      # @api unstable
      # @since 0.1.0
      def initialize(root)
        @root = Pathname.new(root).realpath
        freeze
      end

      # Find all the associated templates to the mailer.
      #
      # It starts under the root path and it **recursively** looks for templates
      # that are matching the given template name.
      #
      # @param template_name [String] the template name
      #
      # @return [Hash] the templates
      #
      # @api unstable
      # @since 0.1.0
      #
      # @example
      #   require 'hanami/mailer'
      #
      #   module Mailers
      #     class Welcome < Hanami::Mailer
      #     end
      #   end
      #
      #   configuration = Hanami::Mailer::Configuration.new do |config|
      #     config.root = "path/to/templates"
      #   end
      #
      #   # This mailer has a template:
      #   #
      #   #   "path/to/templates/welcome.html.erb"
      #
      #   Hanami::Mailer::Rendering::TemplatesFinder.new(root).find("welcome")
      #     # => [#<Hanami::Mailer::Template:0x007f8a0a86a970 ... @file="path/to/templates/welcome.html.erb">]
      def find(template_name)
        templates(template_name).each_with_object({}) do |template, result|
          format         = extract_format(template)
          result[format] = Mailer::Template.new(template)
        end
      end

      protected

      # @api unstable
      # @since 0.1.0
      def templates(template_name, lookup = search_path)
        root_path = [root, lookup, template_name].join(separator)
        search_path = "#{format_separator}#{format}#{format_separator}#{engines}"

        Utils::FileList["#{root_path}#{search_path}"]
      end

      # @api unstable
      # @since 0.1.0
      attr_reader :root

      # @api private
      # @since 0.1.0
      def search_path
        recursive
      end

      # @api private
      # @since 0.1.0
      def recursive
        RECURSIVE
      end

      # @api private
      # @since 0.1.0
      def separator
        ::File::SEPARATOR
      end

      # @api private
      # @since 0.1.0
      def format
        FORMAT
      end

      # @api private
      # @since 0.1.0
      def engines
        ENGINES
      end

      # @api unstable
      # @since next
      def format_separator
        FORMAT_SEPARATOR
      end

      # @api unstable
      # @since next
      def extract_format(template)
        filename = File.basename(template)
        filename.split(format_separator)[-2].to_sym
      end
    end
  end
end
