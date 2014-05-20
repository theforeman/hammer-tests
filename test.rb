#! /usr/bin/env ruby

require 'open4'
require 'colorize'
require './lib.rb'
require './output.rb'
require './utils.rb'


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
  load f
end

logger.log_statistics([cmd_stats, stats])
