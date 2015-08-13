require 'tilt'

module Lotus
  module Mailer
    # A logic-less template.
    #
    # @since 0.1.0
    class Template
      def initialize(template)
        @_template = Tilt.new(template)
      end

      # Render the template within the context of the given scope.
      #
      # @param scope [Lotus::Mailer::Scope] the rendering scope
      #
      # @return [String] the output of the rendering process
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Mailer::Scope
      def render
        @_template.render
      end

      # Get the path to the template
      #
      # @return [String] the pathname
      #
      # @since 0.1.0
      def file
        @_template.file
      end

    end
  end
end
