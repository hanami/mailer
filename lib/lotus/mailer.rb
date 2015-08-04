require 'pathname'
require 'lotus/utils/class_attribute'
require 'lotus/mailer/version'
require 'lotus/mailer/configuration'

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
