require 'xcprofiler'
require 'pathname'

module Danger
  class DangerReporter < Xcprofiler::AbstractReporter
    def initialize(dangerfile, thresholds, inline_mode, working_dir)
      super({})
      @dangerfile = dangerfile
      @thresholds = thresholds
      @inline_mode = inline_mode
      @working_dir = working_dir
    end

    def report!(executions)
      if @inline_mode
        inline_report(executions)
      else
        markdown_report(executions)
      end
    end

    private

    def inline_report(executions)
      executions.each do |execution|
        options = {}
        options[:file] = relative_path(execution.path)
        options[:line] = execution.line
        message = "`#{execution.method_name}` takes #{execution.time} ms to build"

        if execution.time >= @thresholds[:fail]
          @dangerfile.fail(message, options)
        elsif execution.time >= @thresholds[:warn]
          @dangerfile.warn(message, options)
        end
      end
    end

    def markdown_report(executions)
      warning_executions = executions.select do |e|
        e.time >= @thresholds[:warn] && e.time < @thresholds[:fail]
      end
      error_executions = executions.select do |e|
        e.time >= @thresholds[:fail]
      end

      return if warning_executions.empty? && error_executions.empty?

      message = "### Xcprofiler found issues\n\n"
      message << markdown_issues(warning_executions, 'Warnings') unless warning_executions.empty?
      message << markdown_issues(error_executions, 'Errors') unless error_executions.empty?
      @dangerfile.markdown(message, {})
    end

    def relative_path(path)
      working_dir = Pathname.new(@working_dir)
      Pathname.new(path).relative_path_from(working_dir).to_s
    end

    def markdown_issues(executions, heading)
      message = "#### #{heading}\n\n"

      message << "| File | Line | Method Name | Build Time (ms) |\n"
      message << "| ---- | ---- | ----------- | --------------- |\n"

      executions.each do |e|
        message << "| #{e.filename} | #{e.line} | #{e.method_name} | #{e.time} |\n"
      end

      message
    end
  end
end
