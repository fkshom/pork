# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'

require_relative "pork/version"
require_relative "pork/logger"
require_relative "pork/repository"
require_relative "pork/generators/vds_rules"

module Pork
  class Error < StandardError; end
  class << self
    def logger
      @logger ||= Pork::Logger.new.create
    end

    def log_path=(logdev)
      logger.reopen(logdev)
    end

    def log_level=(value)
      logger.level = value1
    end

    def log_level
      %i[DEBUG INFO WARN ERROR FATAL UNKNOWN][logger.level]
    end
  end
end
