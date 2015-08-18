module Lotus
  module Mailer
    # Render mechanism
    #
    # @since 0.1.0
    module Rendering

      # Render a single template with the specified format.
      #
      # @return [String] the output of the rendering process.
      #
      # @since 0.1.0
      def render(format)
        templates
        @templates[format].render
      end

    end
  end
end
