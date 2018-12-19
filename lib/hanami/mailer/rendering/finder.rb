module Hanami
  module Mailer
    module Rendering
      # Find templates for a mailer
      #
      # @api private
      # @since 0.1.0
      #
      # @see Mailer::Template
      module Finder
        # Default format
        #
        # @api private
        # @since 0.1.0
        FORMAT    = '*'.freeze

        # Default template engines
        #
        # @api private
        # @since 0.1.0
        ENGINES   = '*'.freeze

        # Recursive pattern
        #
        # @api private
        # @since 0.1.0
        RECURSIVE = '**'.freeze

        # Find all the associated templates to the mailer.
        # It recursively looks for templates under the root path of the mailer,
        # that are matching the template name
        #
        # @return [Hash] the templates
        #
        # @api private
        # @since 0.1.0
        #
        # @see Hanami::Mailer::Dsl#root
        # @see Hanami::Mailer::Dsl#templates
        #
        # @example
        #   require 'hanami/mailer'
        #
        #   module Mailers
        #     class Welcome
        #       include Hanami::Mailer
        #     end
        #   end
        #
        #   Mailers::Welcome.root     # => "/path/to/templates"
        #   Mailers::Welcome.templates # => {[:html] => "welcome"}
        #
        #   # This mailer has a template:
        #   #
        #   #   "/path/to/templates/welcome.html.erb"
        #
        #   Hanami::Mailer::Rendering::TemplatesFinder.new(Mailers::Welcome).find
        #     # => [#<Hanami::Mailer::Template:0x007f8a0a86a970 ... @file="/path/to/templates/welcome.html.erb">]
        def find
          templates = Hash[]
          _find.map do |template|
            name = File.basename(template)
            format = (name.split('.')[-2]).to_sym
            templates[format] = build_template(template)
          end
          templates
        end

        protected

        # @api private
        # @since 0.1.0
        def _find(lookup = search_path)
          Dir.glob("#{[root, lookup, template_name].join(separator)}.#{format}.#{engines}")
        end

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

        # @api private
        # @since 0.1.0
        def build_template(template)
          Mailer::Template.new(template)
        end
      end
    end
  end
end
