require 'hanami/mailer/rendering/finder'
require 'hanami/mailer/template'

module Hanami
  module Mailer
    module Rendering
      # Find templates for a mailer
      #
      # @api private
      # @since 0.1.0
      #
      # @see Mailer::Template
      class TemplatesFinder
        include Rendering::Finder

        # Initialize a finder
        #
        # @param mailer [Class] the mailer class
        #
        # @api private
        # @since 0.1.0
        def initialize(mailer)
          @mailer = mailer
        end

        protected

        # @api private
        # @since 0.1.0
        def template_name
          Rendering::TemplateName.new(@mailer.template, @mailer.configuration.namespace).to_s
        end

        # @api private
        # @since 0.1.0
        def root
          @mailer.configuration.root
        end
      end
    end
  end
end
