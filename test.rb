#! /usr/bin/env ruby

require 'open4'
require 'colorize'
require './lib.rb'
require './output.rb'
require './utils.rb'

#
# Available environment variables:
#
# HT_HAMMER_CMD       - path to the hammer command (default is hammer)
# HT_TIMESTAMPED_LOGS - use timestamps in names of the output log files, set to 1 to enable the functionality (disabled by default)
# HT_LOGS_LOCATION    - target location for the output logs (default is ./log/)
# HT_FOREMAN_LOG_FILE - path to the Foreman's log (default is /var/log/foreman/development.log)
# HT_HAMMER_LOG_FILE  - path to the Hammer's log (default is ~/.foreman/log/hammer.log)
#
# Example usage:
#
# HT_HAMMER_CMD=./hammer HT_FOREMAN_LOG_FILE=~/foreman/log/development.log ./test.rb ./tests/
#


# Find test files
test_files = []
ARGV.each do|a|
  a = File.expand_path(a)
  if File.directory?(a)
    Dir.glob("#{a}/*.rb").sort.each do |file|
      test_files << file if File.file?(file)
    end
  elsif File.file?(a)
    test_files << a
  end
end

# Load the test files
test_files.each do |f|
  require f
end

logger.log_statistics([cmd_stats, stats])
