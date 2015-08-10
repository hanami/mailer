require 'lotus/mailer/rendering/template_finder'

module Lotus
  module Mailer
    module Rendering
      # Rendering template
      #
      # It's used when a template wants to render another template.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Mailer::Rendering::LayoutScope#render
      #
      # @example
      #   # We have an application template (templates/application.html.erb)
      #   # that uses the following line:
      #
      #   <%= render template: 'articles/show' %>
      class Template
        # Initialize a template
        #
        # @param mailer [Lotus::View] the current mailer
        # @param options [Hash] the rendering informations
        # @option options [Symbol] :format the current format
        # @option options [Hash] :locals the set of objects available within
        #   the rendering context
        #
        # @api private
        # @since 0.1.0
        def initialize(mailer, options)
          @mailer, @options = mailer, options
        end

        # Render the template.
        #
        # @return [String] the output of the rendering process.
        #
        # @api private
        # @since 0.1.0
        def render
          template.render(scope)
        end

        protected
        def template
          TemplateFinder.new(@mailer.class, @options).find
        end

        def scope
         Scope.new(@mailer, @options[:locals])
        end
      end
    end
  end
end
