#! /usr/bin/env ruby

require 'open4'
require 'colorize'
require './loggers.rb'
require './output.rb'
require './utils.rb'

# DUMMY_RUN = true
DUMMY_RUN = false



class CommandResult

  def initialize(code = nil, stdout = "", stderr = "")
    @code = code
    @stdout = stdout
    @stderr = stderr
  end

  attr_accessor :code, :stdout, :stderr

  def ok?
    code == 0
  end
end



def logger
  time_prefix = Time.now.strftime("%Y%m%d_%H%M%S").to_s + "_"
  time_prefix = ""

  if @logger.nil?
    @logger = LoggerContainer.new
    @logger.loggers = [
      OutputLogger.new(),
      OutputLogger.new("./log/#{time_prefix}test.log"),
      LogCropper.new('~/.foreman/log/hammer.log', "./log/#{time_prefix}hammer.fail.log", true),
      LogCropper.new('~/.foreman/log/hammer.log', "./log/#{time_prefix}hammer.log"),
      LogCropper.new('~/foreman/log/development.log', "./log/#{time_prefix}foreman.fail.log", true),
      LogCropper.new('~/foreman/log/development.log', "./log/#{time_prefix}foreman.log")
    ]
  end
  @logger
end

logger.put_header


def hammer(*args)

  if (args[-1].is_a? Hash)
    options = args.pop
    options.collect do |key, value|
      args << "--#{key.to_s.gsub('_', '-')}"
      args << "#{value}"
    end
  end

  @command_cnt ||= 0
  @command_cnt += 1

  result = CommandResult.new

  original_args = args.clone
  original_args.unshift("hammer")

  args.unshift(File.join(File.dirname(__FILE__)) + "/hammer")

  unless DUMMY_RUN
    status = Open4.popen4(*args) do |pid, stdin, stdout, stderr|
      result.stdout = stdout.readlines.join("")
      result.stderr = stderr.readlines.join("")
    end
    result.code = status.exitstatus.to_i
  else
    result.code = 0
  end

  logger.log_command(original_args.join(" "), @command_cnt, result, @current_section)

  return result
end


def section(name, &block)
  @current_section ||= []
  @current_section << name

  logger.log_section(@current_section)
  yield
  @current_section.pop
end

def test(desc, &block)
  result = yield
  logger.log_test(result, desc, @current_section)
end

def simple_test(*args)
  res = hammer *args
  out = ListOutput.new(res.stdout)

  test "returns ok" do
    res.ok?
  end
end

def test_has_columns(out, *column_names)
  column_names.each do |name|
    test "has column #{name}" do
      out.has_column? name
    end
  end
end

def test_column_value(out, column_name, value)
  test "#{column_name} value" do
    out.column(column_name) == value
  end
end



Dir["#{File.join(File.dirname(__FILE__))}/tests/*.rb"].sort.each do |test|
  require test
end

