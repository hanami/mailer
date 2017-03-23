# frozen_string_literal: true
require 'mail'
require 'ice_nine'

module Hanami
  class Mailer
    # @since next
    # @api unstable
    class Finalizer
      # Finalize the given configuration before to start to use the mailers
      #
      # @param mailers [Array<Hanami::Mailer>] all the subclasses of
      #   `Hanami::Mailer`
      # @param configuration [Hanami::Mailer::Configuration] the configuration
      #   to finalize
      #
      # @return configuration [Hanami::Mailer::Configuration] the finalized
      #   configuration
      #
      # @since next
      # @api unstable
      def self.finalize(mailers, configuration)
        Mail.eager_autoload!
        mailers.each { |mailer| configuration.add_mailer(mailer) }

        configuration.freeze
        configuration
      end
    end
  end
end
