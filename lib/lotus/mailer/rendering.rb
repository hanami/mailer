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
          @locals = locals
          @format = locals.fetch(:format, nil)
          @mail   = Mail.new.tap do |m|
            m.from    = __dsl(:from)
            m.to      = __dsl(:to)
            m.subject = __dsl(:subject)

            m.html_part = __part(:html)
            m.text_part = __part(:txt)

            m.delivery_method(*Lotus::Mailer.configuration.delivery_method)
          end
        end

        # Render a single template with the specified format.
        #
        # @param format [Symbol] format
        #
        # @return [String] the output of the rendering process.
        #
        # @raise [Lotus::Mailer::MissingTemplateError] if cannot find a template
        #   associated with the given format.
        #
        # @since 0.1.0
        def render(format)
          self.class.templates(format).render(self, @locals)
        end

        private

        # @private
        # @since 0.1.0
        attr_accessor :mail
      end
    end
  end
end
