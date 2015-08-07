require 'pathname'
require 'lotus/utils/class_attribute'
require 'lotus/mailer/version'
require 'lotus/mailer/configuration'
require 'lotus/mailer/dsl'

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
        extend Dsl.dup

        include Utils::ClassAttribute
        class_attribute :configuration

        self.configuration = conf.duplicate
        self.templates(Hash.new)
      end

      conf.copy!(base)
    end

    def from
      raise self.class.instance_variables.inspect
      if (self.class.instance_variable_get(:@from)).is_a?(Proc)
        instance_exec(&self.class.instance_variable_get(:@from))
      else
        self.class.instance_variable_get(:@from)
      end
    end



    # Load the framework
    #
    # @since 0.1.0
    # @api private
    def self.load!
      configuration.load!
    end

    # Reset the configuration
    def self.reset!
      configuration.reset!
    end

  end
end
