#! /usr/bin/env ruby

require 'open3'
require 'colorize'

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


class LogCropper

  def initialize(log_file, target_file, only_fail=false)
    @log_file = log_file
    @target_file = target_file
    @only_fail = only_fail
    clear_log
    clear_target
  end

  def put_header
    put_line
    put_line "Tests started at: " + Time.now.strftime("%Y/%m/%d %H:%M:%S")
    put_line
  end

  def log(command, command_no, result)
    return if @only_fail and result.ok?
    puts
    put_line "command ##{command_no}"
    puts command
    put_line
    puts get_log
    puts
    clear_log
  end

  protected

  def put_line(text="")
    text = " #{text} " unless text.empty?
    length = 100 - text.length

    line = "--#{text}" + "-"*length
    puts line % text
  end

  def log_file_path
    File.expand_path(@log_file)
  end

  def target_file_path
    File.expand_path(@target_file)
  end

  def get_log
    File.readlines(log_file_path)
  end

  def clear_log
    File.open(log_file_path, 'w') do |f|
    end
  end

  def clear_target
    File.open(target_file_path, 'w') do |f|
    end
  end

  def puts(*args)
    File.open(target_file_path, "a") do |f|
      f.puts(*args)
    end
  end

end



def indent_puts(str)
  indent = "   "*@current_section.size

  str.split("\n").each do |line|
    puts indent+line.rstrip
  end
end


def loggers
  time_prefix = Time.now.strftime("%Y%m%d_%H%M%S").to_s + "_"
  time_prefix = ""

  @loggers ||= [
    LogCropper.new('~/.foreman/log/hammer.log', "./#{time_prefix}hammer.fail.log", true),
    LogCropper.new('~/.foreman/log/hammer.log', "./#{time_prefix}hammer.log"),
    LogCropper.new('~/foreman/log/development.log', "./#{time_prefix}foreman.fail.log", true),
    LogCropper.new('~/foreman/log/development.log', "./#{time_prefix}foreman.log")
  ]
end

loggers.each do |logger|
  logger.put_header
end


def hammer(*args)

  @command_cnt ||= 0
  @command_cnt += 1

  result = CommandResult.new

  original_args = args.clone
  original_args.unshift("hammer")

  #args.unshift("hammer")
  args = ["scl", "enable", "ruby193", "cd /root/hammer/hammer-cli/; bundle exec './bin/hammer "+ args.join(" ") +"'"]

  Open3.popen3(*args) do |stdin, stdout, stderr, wait_thr|
    result.stdout = stdout.readlines.join("")
    result.stderr = stderr.readlines.join("")
    result.code = wait_thr.value.exitstatus.to_i
  end

  indent_puts original_args.join(" ") + "    [command ##{@command_cnt}]".cyan
  unless result.ok?
    indent_puts result.stderr.rstrip.blue
  end

  loggers.each do |logger|
    logger.log(original_args.join(" "), @command_cnt, result)
  end

  return result
end


def section(name, &block)
  @current_section ||= []
  indent_puts name
  @current_section << name
  yield
  @current_section.pop
end

def test(desc, &block)
  result = yield
  if result
    indent_puts "[ OK ] ".green + desc
  else
    indent_puts "[FAIL] ".red + desc
  end
end

def test_has_columns(out, *column_names)
  column_names.each do |name|
    test "has column #{name}" do
      out.has_column? name
    end
  end
end


class Output

  def initialize(output)
    @output = output
  end

  def output
    @output || ""
  end

  def lines
    output.split("\n")
  end

end

class ListOutput < Output

  CELL_DIVIDER = '|'

  def data_lines
    lines.reject{ |line| line.strip =~ /^[|-]*$/}
  end

  def column_titles
    if data_lines.empty?
      []
    else
      data_lines[0].split(CELL_DIVIDER).collect{ |cell| cell.strip.upcase }
    end
  end

  def has_column?(name)
    column_titles.include?(name.upcase)
  end

end

class ShowOutput < Output

  def has_column?(name)
    !lines.find{|line| line.upcase.index(name.upcase) }.nil?
  end

end

require 'pry'

section "architecture" do

  section "list" do
    res = hammer "architecture", "list"
    out = ListOutput.new(res.stdout)

    test "returns ok" do
      res.ok?
    end

    test_has_columns out, "Id", "Name"
  end

  section "info by id" do
    res = hammer "architecture", "info", "--id=1"
    out = ShowOutput.new(res.stdout)

    test "returns ok" do
      res.ok?
    end

    test_has_columns out, "Id", "Name", "OS Ids"

  end
end

