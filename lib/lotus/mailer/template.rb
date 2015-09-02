require 'tilt'
require 'erb'

module Lotus
  module Mailer
    # A logic-less template.
    #
    # @since 0.1.0
    class Template
      def initialize(template)
        engine = template.split('.')[-1]
        @_template = Tilt[engine].new(template)
      end

      # Render the template within the context of the given scope.
      #
      # @param scope [Class] the rendering scope
      # @param locals [Hash] set of objects passed to the constructor
      #
      # @return [String] the output of the rendering process
      #
      # @api private
      # @since 0.1.0
      def render(scope = Object.new, locals = {})
        @_template.render(scope, locals)
      end

      # Get the template's name
      #
      # @return [String] template's name
      #
      # @since 0.1.0
      def name
        name = @_template.file.split('/')[-1]
        name.split('.')[0] + "." + name.split('.')[1]
      end
    end
  end
end
