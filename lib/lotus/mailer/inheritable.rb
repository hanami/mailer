module Lotus
  module Mailer
    # Inheriting mechanisms
    #
    # @since 0.1.0
    module Inheritable
      # Register a mailer subclass
      #
      # @api private
      # @since 0.1.0
      #
      # @example
      #   require 'lotus/mailer'
      #
      #   class IndexMailer
      #     include Lotus::Mailer
      #   end
      #
      #   class JsonIndexMailer < IndexMailer
      #   end
      def inherited(base)
        subclasses.add base
      end

      # Set of registered subclasses
      #
      # @api private
      # @since 0.1.0
      def subclasses
        @@subclasses ||= Set.new
      end

      protected
      # Loading mechanism hook.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Mailer.load!
      def load!
        subclasses.freeze
        mailers.freeze
      end

      # Registered mailers
      #
      # @api private
      # @since 0.1.0
      def mailers
        @@mailers ||= [ self ] + subclasses.to_a
      end
    end
  end
end
