require 'lotus/mailer/rendering/templates_finder'

module Lotus
  module Mailer
    module Rendering
      # Find a template for the current mailer context.
      # It's used when a template wants to render another template.
      #
      # @see Lotus::Mailer::Rendering::Template
      # @see Lotus::Mailer::Rendering::TemplatesFinder
      #
      # @api private
      # @since 0.1.0
      class TemplateFinder < TemplatesFinder
        # Initialize a finder
        #
        # @param view [Class] a mailer
        # @param options [Hash] the informations about the context
        # @option options [String] :template the template file name
        # @option options [Symbol] :format the requested format
        #
        # @api private
        # @since 0.1.0
        def initialize(mailer, options)
          super(mailer)
          @options = options
        end

        # Find a template for the current view context
        #
        # @return [Lotus::Mailer::Template] the requested template
        #
        # @api private
        # @since 0.1.0
        #
        # @see Lotus::Mailer::Rendering::TemplatesFinder#find
        # @see Lotus::Mailer::Rendering::Template#render
        def find
          super.first
        end

        protected
        def template_name
          @options[:template]
        end

        def format
          @options[:format]
        end
      end
    end
  end
end
