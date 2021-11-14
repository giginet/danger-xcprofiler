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
  # @example Specify a custom DerivedData directory
  #
  #          xcprofiler.report 'MyApp' './DerivedData'
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

    # A globbed string or array of strings which should match the files
    # that you want to ignore warnings on. Defaults to nil.
    # An example would be `'**/Pods/**'` to ignore warnings in Pods that your project uses.
    #
    # @param    [String or [String]] value
    # @return   [[String]]
    attr_accessor :ignored_files

    # Search the latest .xcactivitylog by the passing product_name and profile compilation time
    # @param    [String] product_name Product name for the target project.
    # @param    [String] derived_data_path Path to the directory containing the DerivedData.
    # @param    [String] log_path Path to the xcactivitylog to process.
    # @return   [void]
    def report(product_name, derived_data_path = nil, log_path = nil)

      if log_path && log_path.end_with?('.xcactivitylog')
        profiler = Xcprofiler::Profiler.by_path(log_path)
      else
        profiler = Xcprofiler::Profiler.by_product_name(product_name, derived_data_path)
      end

      profiler.reporters = [
        DangerReporter.new(@dangerfile, thresholds, inline_mode, working_dir, ignored_files)
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

      !!@inline_mode
    end
  end
end
