require 'lotus/mailer/rendering/template_name'
require 'lotus/mailer/rendering/templates_finder'

module Lotus
  module Mailer
    # Class level DSL
    #
    # @since 0.1.0
    module Dsl
      # When a value is given, specify a templates root path for the mailer.
      # Otherwise, it returns templates root path.
      #
      # When not initialized, it will return the global value from `Lotus::Mailer.root`.
      #
      # @param value [String] the templates root for this mailer
      #
      # @return [Pathname] the specified root for this mailer or the global value
      #
      # @since 0.1.0
      #
      # @example Default usage
      #   require 'lotus/mailer'
      #
      #   module Articles
      #     class Show
      #       include Lotus::Mailer
      #     end
      #   end
      #
      #   Lotus::Mailer.configuration.root # => 'app/templates'
      #   Articles::Show.root            # => 'app/templates'
      #
      # @example Custom root
      #   require 'lotus/mailer'
      #
      #   module Articles
      #     class Show
      #       include Lotus::Mailer
      #       root 'path/to/articles/templates'
      #     end
      #   end
      #
      #   Lotus::Mailer.configuration.root # => 'app/templates'
      #   Articles::Show.root            # => 'path/to/articles/templates'
      def root(value = nil)
        if value.nil?
          configuration.root
        else
          configuration.root(value)
        end
      end

      # When a value is given, specify the relative path to the template.
      # Otherwise, it returns the name that follows Lotus::Mailer conventions.
      #
      # @param format [Symbol] template format
      # @param value [String] relative template path
      #
      # @return [Template] the template with the correspondent format for the mailer
      #
      # @since 0.1.0
      #
      # @example Custom template
      #   require 'lotus/mailer'
      #
      #   module Articles
      #     class Show
      #       include Lotus::Mailer
      #       template :json, 'articles/single_article'
      #     end
      #
      #   Articles::Show.template(:json)      # 'articles'
      def template(format = nil, value = nil)
        if value.nil?
          if !@templates.has_key?(format)
            @templates[format] = Rendering::TemplateName.new(name, configuration.namespace).to_s
          end
        else
          @templates[format] = Mailer::Template.new("#{ [root, value].join('/') }")
        end
      end

      # Returns the Hash with all the templates of the mailer
      #
      # @return [Hash] the Hash with the templates
      #
      # @since 0.1.0
      def templates(value = nil)
        if value.nil?
          # If no templates are given, use the default templates instead
          if @templates.empty?
            @templates = Mailer::Rendering::TemplatesFinder.new(self).find
          else
            @templates
          end
        else
          @templates = value
        end
      end

      protected

      # Loading mechanism hook.
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Mailer.load!
      def load!
        super
        mailers.each do |m|
          m.root.freeze
          m.format.freeze
          m.templates.freeze
          m.configuration.freeze
        end
      end
    end
  end
end
