require 'xcprofiler'
require_relative 'danger_reporter'

module Danger
  class DangerXcprofiler < Plugin

    # Defines path for working directory
    # Default value is `Dir.pwd`
    # @params    [String] value
    # @return    [String]
    #
    attr_accessor :working_dir

    # Defines threshold of completion time (ms) to assert warning/failure
    # Default value is `{ warn: 100, fail: 500 }`
    # @param    [Hash<String, String>] value
    # @return   [Hash<String, String>]
    #
    attr_accessor :thresholds

    # Defines if using inline comment to assert
    # Default value is `true`
    # @param    [Boolean] value
    # @return   [Boolean]
    #
    attr_accessor :inline_mode

    def report(product_name)
      profiler = Xcprofiler::Profiler.by_product_name(product_name)
      profiler.reporters = [
          DangerReporter.new(@dangerfile, thresholds, inline_mode, working_dir)
      ]
      profiler.report!
    rescue Xcprofiler::DerivedDataNotFound, Xcprofiler::BuildFlagIsNotEnabled => e
      warn(e.message)
    end

    private

    def working_dir
      @working_dir || Dir.pwd
    end

    def thresholds
      @thresholds || { warn: 50, fail: 100 }
    end

    def inline_mode
      return !!@inline_mode unless @inline_mode.nil?
      true
    end
  end
end
