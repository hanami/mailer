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

      # Initialize a configuration instance
      #
      # @return [Lotus::Mailer::Configuration] a new configuration's instance
      #
      # @since 0.1.0
      def initialize
        reset!
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

      # Load the configuration
      def load!
        freeze
      end

      # Reset the configuration
      def reset!
        root(DEFAULT_ROOT)
      end

      alias_method :unload!, :reset!

      protected
      attr_writer :root
      
    end
  end
end
