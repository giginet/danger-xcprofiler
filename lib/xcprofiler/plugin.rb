require 'xcprofiler'
require_relative 'danger_reporter'

module Danger
  # Asserts compilation time of each methods if these are exceeded the specified thresholds
  # @example Asserting compilation time of 'MyApp'
  #
  #          xcprofiler.report 'MyApp'
  #
  # @example Define thresholds (ms)
  #
  #          xcprofiler.thresholds = { warn: 100, fail: 500 }
  #          xcprofiler.report 'MyApp'
  #
  # @see  giginet/danger-xcprofiler
  # @tags xcode, ios, danger
  class DangerXcprofiler < Plugin
    # Defines path for working directory
    # Default value is `Dir.pwd`
    # @param     [String] value
    # @return    [String]
    attr_accessor :working_dir

    # Defines threshold of compilation time (ms) to assert warning/failure
    # Default value is `{ warn: 100, fail: 500 }`
    # @param    [Hash<String, String>] value
    # @return   [Hash<String, String>]
    attr_accessor :thresholds

    # Defines if using inline comment to assert
    # Default value is `true`
    # @param    [Boolean] value
    # @return   [Boolean]
    attr_accessor :inline_mode

    # Search the latest .xcactivitylog by the passing product_name and profile compilation time
    # @param    [String] product_name Product name for the target project.
    # @return   [void]
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
      return true if @inline_mode.nil?
      @inline_mode
    end
  end
end
