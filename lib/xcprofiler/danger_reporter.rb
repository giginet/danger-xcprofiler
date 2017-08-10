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
      executions.each do |execution|
        options = {}
        message = "`#{execution.method_name}` takes #{execution.time} ms to build"
        if @inline_mode
          options[:file] = relative_path(execution.path)
          options[:line] = execution.line
        else
          message = "`#{execution.method_name}` in `#{execution.filename}` takes #{execution.time} ms to build"
        end
        if execution.time >= @thresholds[:fail]
          @dangerfile.fail(message, options)
        elsif execution.time >= @thresholds[:warn]
          @dangerfile.warn(message, options)
        end
      end
    end

    private

    def relative_path(path)
      working_dir = Pathname.new(@working_dir)
      Pathname.new(path).relative_path_from(working_dir).to_s
    end
  end
end
