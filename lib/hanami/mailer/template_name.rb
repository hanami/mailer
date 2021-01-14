# frozen_string_literal: true

require "hanami/utils/string"

module Hanami
  class Mailer
    # @since 0.1.0
    # @api private
    #
    # TODO this is identical to Hanami::View, consider to move into Hanami::Utils
    class TemplateName
      # @since next
      # @api unstable
      def self.call(name, namespace)
        Utils::String.underscore(name.gsub(/\A#{namespace}(::)*/, ""))
      end

      class << self
        # @since next
        # @api unstable
        alias_method :[], :call
      end
    end
  end
end
