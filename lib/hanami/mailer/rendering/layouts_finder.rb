require 'hanami/mailer/rendering/finder'
require 'hanami/mailer/layout'

module Hanami
  module Mailer
    module Rendering
      # Find layouts for a mailer
      #
      # @api private
      # @since 0.3.0
      #
      # @see Mailer::layout
      class LayoutsFinder
        include Rendering::Finder

        # Folder for templates
        #
        # @api private
        # @since 0.1.0
        FOLDER = 'layouts'.freeze

        # Initialize a finder
        #
        # @param mailer [Class] the mailer class
        #
        # @api private
        # @since 0.3.0
        def initialize(mailer)
          @mailer = mailer
        end

        protected

        # @api private
        # @since 0.3.0
        def template_name
          Rendering::TemplateName.new(@mailer.layout, @mailer.configuration.namespace).to_s
        end

        # @api private
        # @since 0.3.0
        def root
          [@mailer.configuration.root, FOLDER].join(separator)
        end

        # @api private
        # @since 0.3.0
        def build_template(template)
          Mailer::Layout.new(template)
        end
      end
    end
  end
end
