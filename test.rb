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


def indent_puts(str)
  indent = "   "*@current_section.size
  
  str.split("\n").each do |line|
    puts indent+line.rstrip
  end
end

def hammer(*args)

  @command_cnt ||= 0
  @command_cnt += 1

  result = CommandResult.new

  args.unshift("hammer")
  Open3.popen3(*args) do |stdin, stdout, stderr, wait_thr|
    result.stdout = stdout.readlines.join("")
    result.stderr = stderr.readlines.join("")
    result.code = wait_thr.value.exitstatus.to_i
  end

  if result.ok?
    indent_puts args.join(" ")
    #indent_puts result.stdout
  else
    indent_puts args.join(" ") + "    [command ##{@command_cnt}]".cyan
    indent_puts result.stderr.rstrip.blue
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

