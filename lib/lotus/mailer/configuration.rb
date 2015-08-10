require 'pathname'
require 'lotus/utils/class'
require 'lotus/utils/kernel'
require 'lotus/utils/string'
require 'lotus/utils/load_paths'

module Lotus
  module Mailer
    class Configuration
      # Default root
      #
      # @since 0.1.0
      # @api private
      DEFAULT_ROOT = '.'.freeze

      attr_reader :mailers
      attr_reader :modules
      # Initialize a configuration instance
      #
      # @return [Lotus::Mailer::Configuration] a new configuration's instance
      #
      # @since 0.1.0
      def initialize
        @namespace = Object
        reset!
      end

      # Return the original configuration of the framework instance associated
      # with the given class.
      #
      # When multiple instances of Lotus::Mailer are used in the same application,
      # we want to make sure that a controller or an action will  receive the
      # expected configuration.
      #
      # @param base [Class] a mailer
      #
      # @return [Lotus::Controller::Configuration] the configuration associated
      #   to the given class.
      #
      # @since 0.1.0
      # @api private
      #
      # @example Direct usage of the framework
      #   require 'lotus/mailer'
      #
      #   class Show
      #     include Lotus::Mailer
      #   end
      #
      #   Lotus::Mailer::Configuration.for(Show)
      #     # => will return from Lotus::Mailer
      #
      # @example Multiple instances of the framework
      #   require 'lotus/mailer'
      #
      #   module MyApp
      #     Mailer = Lotus::Mailer.duplicate(self)
      #
      #     module Mailers::Dashboard
      #       class Index
      #         include MyApp::Mailer
      #       end
      #     end
      #   end
      #
      #   class Show
      #     include Lotus::Action
      #   end
      #
      #   Lotus::Mailer::Configuration.for(Show)
      #     # => will return from Lotus::Mailer
      #
      #   Lotus::Mailer::Configuration.for(MyApp::Views::Dashboard::Index)
      #     # => will return from MyApp::Mailer
      def self.for(base)
        namespace = Utils::String.new(base).namespace
        framework = Utils::Class.load_from_pattern!("(#{namespace}|Lotus)::Mailer")
        framework.configuration
      end

      # Set the Ruby namespace where to lookup for mailers.
      #
      # When multiple instances of the framework are used, we want to make sure
      # that if a `MyApp` wants a `Dashboard::Index` mailer, we are loading the
      # right one.
      #
      # If not set, this value defaults to `Object`.
      #
      # This is part of a DSL, for this reason when this method is called with
      # an argument, it will set the corresponding instance variable. When
      # called without, it will return the already set value, or the default.
      #
      # @overload namespace(value)
      #   Sets the given value
      #   @param value [Class, Module, String] a valid Ruby namespace identifier
      #
      # @overload namespace
      #   Gets the value
      #   @return [Class, Module, String]
      #
      # @since 0.1.0
      #
      # @example Getting the value
      #   require 'lotus/mailer'
      #
      #   Lotus::Mailer.configuration.namespace # => Object
      #
      # @example Setting the value
      #   require 'lotus/mailer'
      #
      #   Lotus::Mailer.configure do
      #     namespace 'MyApp::Mailers'
      #   end
      def namespace(value = nil)
        if value
          @namespace = value
        else
          @namespace
        end
      end

      # Set the root path where to search for templates
      #
      # If not set, this value defaults to the current directory.
      #
      # When this method is called with an argument, it will set the corresponding instance variable.
      # When called without, it will return the already set value, or the default.
      #
      # @overload root(value)
      #   Sets the given value
      #   @param value [String,Pathname,#to_pathname] an object that can be
      #     coerced to Pathname
      #
      # @overload root
      #   Gets the value
      #   @return [Pathname]
      #
      # @since 0.1.0
      #
      # @see http://www.ruby-doc.org/stdlib-2.1.2/libdoc/pathname/rdoc/Pathname.html
      # @see http://rdoc.info/gems/lotus-utils/Lotus/Utils/Kernel#Pathname-class_method
      #
      # @example Getting the value
      #   require 'lotus/mailer'
      #
      #   Lotus::Mailer.configuration.root # => #<Pathname:.>
      #
      # @example Setting the value
      #   require 'lotus/mailer'
      #
      #   Lotus::Mailer.configure do
      #     root '/path/to/templates'
      #   end
      #
      #   Lotus::Mailer.configuration.root # => #<Pathname:/path/to/templates>
      def root(value = nil)
        if value
          @root = Utils::Kernel.Pathname(value).realpath
        else
          @root
        end
      end

      # Prepare the mailers.
      #
      # The given block will be yielded when `Lotus::Mailer` will be included by
      # a mailer.
      #
      # This method can be called multiple times.
      #
      # @param blk [Proc] the code block
      #
      # @return [void]
      #
      # @raise [ArgumentError] if called without passing a block
      #
      # @since 0.1.0
      #
      # @see Lotus::Mailer.configure
      # @see Lotus::Mailer.duplicate
      def prepare(&blk)
        if block_given?
          @modules.push(blk)
        else
          raise ArgumentError.new('Please provide a block')
        end
      end

      # Add a mailer to the registry
      #
      # @since 0.1.0
      # @api private
      def add_mailer(mailer)
        @mailers.add(mailer)
      end

      # Duplicate by copying the settings in a new instance.
      #
      # @return [Lotus::Mailer::Configuration] a copy of the configuration
      #
      # @since 0.1.0
      # @api private
      def duplicate
        Configuration.new.tap do |c|
          c.namespace  = namespace
          c.root       = root
          c.modules    = modules.dup
        end
      end

      # Load the configuration
      def load!
        mailers.each { |m| m.__send__(:load!) }
        freeze
      end

      # Reset the configuration
      def reset!
        root(DEFAULT_ROOT)

        @mailers      = Set.new
        @modules    = []
      end

      # Copy the configuration for the given action
      #
      # @param base [Class] the target action
      #
      # @return void
      #
      # @since 0.1.0
      # @api private
      def copy!(base)
        modules.each do |mod|
          base.class_eval(&mod)
        end
      end

      alias_method :unload!, :reset!

      protected
      attr_writer :root
      attr_writer :namespace
      attr_writer :modules
    end
  end
end
