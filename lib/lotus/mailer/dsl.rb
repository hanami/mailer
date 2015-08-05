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
      # @param value [String] relative template path
      #
      # @return [String] the default template name for this mailer
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
      #   Articles::Show.templates     # :json => 'articles/single_article'
      #   Articles::Show.template      # 'articles'
      #
      # @example With nested namespace
      #   require 'lotus/mailer'
      #
      #   module Frontend
      #     View = Lotus::Mailer.generate(self)
      #
      #     class InvoiceMailer
      #       include Frontend::Mailer
      #     end
      #
      #     module Mailers
      #       class Invoice
      #         include Frontend::Mailer
      #       end
      #
      #       module Sessions
      #         class New
      #           include Frontend::Mailer
      #         end
      #       end
      #     end
      #   end
      #
      #   Frontend::InvoiceMailer.template       # => 'standalone_mailer'
      #   Frontend::Mailers::Invoice.template    # => 'standalone'
      #   Frontend::Views::Sessions::New.template # => 'sessions/new'
      def template(key=nil, value = nil)
        if value.nil?
          @template ||= Rendering::TemplateName.new(name, configuration.namespace).to_s
        else
          @templates[key] = value
        end
      end
      
      # Returns the Hash with all the templates of the mailer
      #
      # @return [String] the Hash with the templates
      #
      # @since 0.1.0
      #
      # @example fetch templates
      #   require 'lotus/mailer'
      #   class InvoiceMailer
      #     include Lotus::Mailer
      #     self.templates
      #   end
      def templates (value = nil)
        if value.nil?
          @templates
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
        find_templates
        mailers.each do |m|
          m.root.freeze
          m.format.freeze
          m.templates.freeze
          m.configuration.freeze
        end
      end
      
      # Find templates matching class name in the root folder
      # with TemplatesFinder
      #
      # @api private
      # @since 0.1.0
      #
      # @see Lotus::Mailer.load!
      def find_templates
        @templates = Rendering::TemplatesFinder.new(configuration.namespace)
      end
    end
  end
end
