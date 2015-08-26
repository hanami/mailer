module Lotus
  module Mailer
    # Render mechanism
    #
    # @since 0.1.0
    module Rendering
      def self.extended(base)
        base.class_eval do
          include InstanceMethods
        end
      end

      module InstanceMethods
        # Initialize a mailer
        #
        # @param locals [Hash] a set of objects available during the rendering process.
        #
        # @since 0.1.0
        def initialize(locals = {})
          @locals   = locals
          @scope    = self
          @mail = Mail.new
        end

        # Render a single template with the specified format.
        #
        # @param format [symbol] template's format
        #
        # @return [String] the output of the rendering process.
        #
        # @since 0.1.0
        def render(format)
          self.class.templates
          self.class.templates[format].render @scope, @locals
        end

        attr_accessor :mail
      end
    end
  end
end
