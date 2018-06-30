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
        # Default format
        #
        # @api private
        # @since 0.3.0
        FORMAT    = '*'.freeze

        # Default layout engines
        #
        # @api private
        # @since 0.3.0
        ENGINES   = '*'.freeze

        # Recursive pattern
        #
        # @api private
        # @since 0.3.0
        RECURSIVE = '**'.freeze

        # Initialize a finder
        #
        # @param mailer [Class] the mailer class
        #
        # @api private
        # @since 0.3.0
        def initialize(mailer)
          @mailer = mailer
        end

        # Find all the associated layouts to the mailer.
        # It recursively looks for layouts under the root path of the mailer,
        # that are matching the layout name
        #
        # @return [Hash] the layouts
        #
        # @api private
        # @since 0.3.0
        #
        # @see Hanami::Mailer::Dsl#layouts
        #
        # @example
        #   require 'hanami/mailer'
        #
        #   module Mailers
        #     class Welcome
        #       include Hanami::Mailer
        #       layout 'mailer'
        #     end
        #   end
        #
        #   Mailers::Welcome.layouts # => {[:html] => "mailer"}
        #
        #   # This mailer has a layout:
        #   #
        #   #   "/path/to/layouts/mailer.html.erb"
        #
        #   Hanami::Mailer::Rendering::LayoutsFinder.new(Mailers::Welcome).find
        #     # => [#<Hanami::Mailer::Layout:0x007f8a0a86a970 ... @file="/path/to/layouts/mailer.html.erb">]
        def find
          layouts = Hash[]
          _find.map do |layout|
            name = File.basename(layout)
            format = (name.split('.')[-2]).to_sym
            layouts[format] = Mailer::Layout.new(layout)
          end
          layouts
        end

        protected

        # @api private
        # @since 0.3.0
        def _find(lookup = search_path)
          Dir.glob("#{[root, lookup, layout_name].join(separator)}.#{format}.#{engines}")
        end

        # @api private
        # @since 0.3.0
        def layout_name
          Rendering::TemplateName.new(@mailer.layout, @mailer.configuration.namespace).to_s
        end

        # @api private
        # @since 0.3.0
        def root
          [@mailer.configuration.root, 'layouts'].join(separator)
        end

        # @api private
        # @since 0.3.0
        def search_path
          recursive
        end

        # @api private
        # @since 0.3.0
        def recursive
          RECURSIVE
        end

        # @api private
        # @since 0.3.0
        def separator
          ::File::SEPARATOR
        end

        # @api private
        # @since 0.3.0
        def format
          FORMAT
        end

        # @api private
        # @since 0.3.0
        def engines
          ENGINES
        end
      end
    end
  end
end
