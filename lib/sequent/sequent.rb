require_relative 'core/core'
require_relative 'migrations/migrations'
require_relative 'test/test'
require_relative 'configuration'

require 'logger'

module Sequent
  def self.logger
    @logger ||= Logger.new(STDOUT).tap {|l| l.level = Logger::INFO }
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.configure
    yield Configuration.instance
  end

  def self.configuration
    Configuration.instance
  end

  # Short hand for Sequent.configuration.command_service
  def self.command_service
    configuration.command_service
  end
end
