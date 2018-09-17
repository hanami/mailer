require 'hanami/utils/kernel'
require 'tilt'

module Hanami
  module Mailer
    # A logic-less layout.
    #
    # @api private
    # @since 0.1.0
    class Layout
      def initialize(layout)
        @_layout = Tilt.new(layout)
      end

      # Render the layout within the context of the given scope.
      #
      # @param scope [Class] the rendering scope
      # @param locals [Hash] set of objects passed to the constructor
      #
      # @return [String] the output of the rendering process
      #
      # @api private
      # @since 0.1.0
      def render(scope = Object.new, locals = {}, &block)
        @_layout.render(scope, locals, &block)
      end

      # Get the path to the layout
      #
      # @return [String] the pathname
      #
      # @api private
      # @since 0.1.0
      def file
        @_layout.file
      end

      # Checks for the existence of layout
      #
      # @return [Bool]
      #
      # @api private
      # @since 0.1.0
      def exist?
        return false if file.nil?
        Utils::Kernel.Pathname(file).exist?
      end
    end
  end
end
