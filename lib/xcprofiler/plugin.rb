module Danger
  class DangerXcprofiler < Plugin

    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [Array<String>]
    attr_accessor :my_attribute

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #
    def warn_on_mondays
      warn 'Trying to merge code on a Monday' if Date.today.wday == 1
    end
  end
end
