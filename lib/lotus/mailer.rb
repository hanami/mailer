require 'pathname'
require 'lotus/utils/class_attribute'
require 'lotus/mailer/version'
require 'lotus/mailer/configuration'
require 'lotus/mailer/dsl'
require 'lotus/mailer/inheritable'

module Lotus
  module Mailer
    include Utils::ClassAttribute

    class_attribute :configuration
    self.configuration = Configuration.new

    # Configure the framework.
    # It yields the given block in the context of the configuration
    #
    # @param blk [Proc] the configuration block
    #
    # @since 0.1.0
    #
    # @see Lotus::Mailer::Configuration
    #
    # @example
    #   require 'lotus/mailer'
    #
    #   Lotus::Mailer.configure do
    #     root '/path/to/root'
    #   end
    def self.configure(&blk)
      configuration.instance_eval(&blk)
    end

    # Duplicate Lotus::Mailer in order to create a new separated instance
    # of the framework.
    #
    # The new instance of the framework will be completely decoupled from the
    # original. It will inherit the configuration, but all the changes that
    # happen after the duplication, won't be reflected on the other copies.
    #
    # @return [Module] a copy of Lotus::Mailer
    #
    # @since 0.1.0
    # @api private
    #
    # @example Basic usage
    #   require 'lotus/mailer'
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.dupe
    #   end
    #
    #   MyApp::Mailer == Lotus::Mailer # => false
    #
    #   MyApp::Mailer.configuration ==
    #     Lotus::Mailer.configuration # => false
    #
    # @example Inheriting configuration
    #   require 'lotus/mailer'
    #
    #   Lotus::Mailer.configure do
    #     root '/path/to/root'
    #   end
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.dupe
    #   end
    #
    #   module MyApi
    #     Mailer = Lotus::Mailer.dupe
    #     Mailer.configure do
    #       root '/another/root'
    #     end
    #   end
    #
    #   Lotus::Mailer.configuration.root # => #<Pathname:/path/to/root>
    #   MyApp::Mailer.configuration.root # => #<Pathname:/path/to/root>
    #   MyApi::Mailer.configuration.root # => #<Pathname:/another/root>
    def self.dupe
      dup.tap do |duplicated|
        duplicated.configuration = configuration.duplicate
      end
    end

    # Duplicate the framework and generate modules for the target application
    #
    # @param mod [Module] the Ruby namespace of the application
    # @param mailers [String] the optional namespace where the application's
    #   mailers will live
    # @param blk [Proc] an optional block to configure the framework
    #
    # @return [Module] a copy of Lotus::Mailer
    #
    # @since 0.1.0
    #
    # @see Lotus::Mailer#dupe
    # @see Lotus::Mailer::Configuration
    # @see Lotus::Mailer::Configuration#namespace
    #
    # @example Basic usage
    #   require 'lotus/mailer'
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.duplicate(self)
    #   end
    #
    #   # It will: (TODO: REVIEW THIS)
    #   #
    #   # 1. Generate MyApp::Mailer
    #   # 2. Generate MyApp::Mailers
    #   # 3. Configure MyApp::Mailers as the default namespace for mailers
    #
    #  module MyApp::Mailers::Dashboard
    #    class Index
    #      include MyApp::Mailer
    #    end
    #  end
    #
    # @example Compare code
    #   require 'lotus/mailer'
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.duplicate(self) do
    #       # ...
    #     end
    #   end
    #
    #   # it's equivalent to:
    #
    #   module MyApp
    #     Mailer   = Lotus::Mailer.dupe
    #     Layout = Lotus::Layout.dup
    #
    #     module Mailers
    #     end
    #
    #     Mailer.configure do
    #       namespace 'MyApp::Mailers'
    #     end
    #
    #     Mailer.configure do
    #       # ...
    #     end
    #   end
    #
    # @example Custom mailers module
    #   require 'lotus/mailers
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.duplicate(self, 'Vs')
    #   end
    #
    #   defined?(MyApp::Mailers) # => nil
    #   defined?(MyApp::Vs)    # => "constant"
    #
    #   # Developers can namespace mailers under Vs
    #   module MyApp::Vs::Dashboard
    #     # ...
    #   end
    #
    # @example Nil mailers module
    #   require 'lotus/mailer'
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.duplicate(self, nil)
    #   end
    #
    #   defined?(MyApp::Views) # => nil
    #
    #   # Developers can namespace mailers under MyApp
    #   module MyApp
    #     # ...
    #   end
    #
    # @example Block usage
    #   require 'lotus/mailer'
    #
    #   module MyApp
    #     Mailer = Lotus::Mailer.duplicate(self) do
    #       root '/path/to/root'
    #     end
    #   end
    #
    #   Lotus::Mailer.configuration.root # => #<Pathname:.>
    #   MyApp::Mailer.configuration.root # => #<Pathname:/path/to/root>
    def self.duplicate(mod, mailers = 'Mailers', &blk)
      dupe.tap do |duplicated|
        mod.module_eval %{ module #{ mailers }; end } if mailers
        # mod.module_eval %{
        #   Layout = Lotus::Layout.dup
        #   Presenter = Lotus::Presenter.dup
        # }

        duplicated.configure do
          namespace [mod, mailers].compact.join '::'
        end

        duplicated.configure(&blk) if block_given?
      end
    end

    # Override Ruby's hook for modules.
    # It includes basic Lotus::Mailer modules to the given Class.
    # It sets a copy of the framework configuration
    #
    # @param base [Class] the target mailer
    #
    # @since 0.1.0
    # @api private
    #
    # @see http://www.ruby-doc.org/core-2.1.2/Module.html#method-i-included
    #
    # @example
    #   require 'lotus/mailer'
    #
    #   class IndexMailer
    #     include Lotus::Mailer
    #   end
    def self.included(base)
      conf = self.configuration
      conf.add_mailer(base)

      base.class_eval do
        extend Inheritable.dup
        extend Dsl.dup
        # extend Rendering.dup
        # extend Escape.dup

        include Utils::ClassAttribute
        class_attribute :configuration

        self.configuration = conf.duplicate
        self.templates(Hash.new)

      end

      conf.copy!(base)
    end

    # Load the framework
    #
    # @since 0.1.0
    # @api private
    def self.load!
      puts 'here'
      configuration.load!
    end

    # Reset the configuration
    def self.reset!
      configuration.reset!
    end

  end
end
