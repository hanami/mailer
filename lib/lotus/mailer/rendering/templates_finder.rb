require 'lotus/mailer/template'

module Lotus
  module Mailer
    module Rendering
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
        FORMAT    = '*'.freeze

        # Default template engines
        #
        # @api private
        # @since 0.1.0
        ENGINES   = '*'.freeze

        # Recursive pattern
        #
        # @api private
        # @since 0.2.0
        RECURSIVE = '**'.freeze

        # Initialize a finder
        #
        # @param view [Class] the mailer
        #
        # @api private
        # @since 0.1.0
        def initialize(mailer)
          @mailer = mailer
        end

        # Find all the associated templates to the mailer.
        # It recursively looks for templates under the root path of the mailer,
        # that are matching the template name
        #
        # @return [Hash] the templates
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::Mailer::Dsl#root
        # @see Lotus::Mailer::Dsl#templates
        #
        # @example
        #   require 'lotus/mailer'
        #
        #   module Articles
        #     class Show
        #       include Lotus::Mailer
        #     end
        #   end
        #
        #   Articles::Show.root     # => "/path/to/templates"
        #   Articles::Show.templates # => {[:html] => "articles/show"}
        #
        #   # This mailer has a template:
        #   #
        #   #   "/path/to/templates/articles/show.html.erb"
        #
        #   Lotus::Mailer::Rendering::TemplatesFinder.new(Articles::Show).find
        #     # => [#<Lotus::Mailer::Template:0x007f8a0a86a970 ... @file="/path/to/templates/articles/show.html.erb">]
        def find
          templates = Hash.new
          _find.map do |template|
            name = File.basename(template)
            format = (( name.split(".") )[-2]).to_sym
            templates[ format ] = Mailer::Template.new(template)
          end
          return templates
        end

        protected

        # @api private
        # @since 0.4.3
        def _find(lookup = search_path)
          Dir.glob( "#{ [root, lookup, template_name].join(separator) }.#{ format }.#{ engines }" )
        end

        # @api private
        # @since 0.1.0
        def template_name
          @mailer.template
        end

        # @api private
        # @since 0.1.0
        def root
          @mailer.root
        end

        # @api private
        # @since 0.4.3
        def search_path
          recursive
        end

        # @api private
        # @since 0.2.0
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
      end
    end
  end
end
