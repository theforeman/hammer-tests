require './loggers.rb'

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


class Statistics

  def initialize(name)
    @name = name
    @failure_count = 0
    @success_count = 0
  end

  attr_accessor :name, :success_count, :failure_count

  def add_test(result)
    if result
      @success_count += 1
    else
      @failure_count += 1
    end
  end

  def total
    @failure_count + @success_count
  end

end


def stats
  @stats ||= Statistics.new("Tests")
  @stats
end

def cmd_stats
  @cmd_stats ||= Statistics.new("Commands")
  @cmd_stats
end

def logger
  time_prefix = ""
  if (ENV['HT_TIMESTAMPED_LOGS'] == '1')
    time_prefix = Time.now.strftime("%Y%m%d_%H%M%S").to_s + "_"
  end

  log_location = ENV['HT_LOGS_LOCATION'] || "./log/"
  hammer_log_file = ENV['HT_HAMMER_LOG_FILE'] || "~/.foreman/log/hammer.log"           # '~/.foreman/log/hammer.log'
  foreman_log_file = ENV['HT_FOREMAN_LOG_FILE'] || "/var/log/foreman/development.log"  # '~/foreman/log/development.log'


  if @logger.nil?
    @logger = LoggerContainer.new
    @logger.loggers = [
      OutputLogger.new(),
      OutputLogger.new("#{log_location}/#{time_prefix}test.log", false),
      OutputLogger.new("#{log_location}/#{time_prefix}test.color.log", true),
      LogCropper.new(hammer_log_file, "#{log_location}/#{time_prefix}hammer.fail.log", true),
      LogCropper.new(hammer_log_file, "#{log_location}/#{time_prefix}hammer.log"),
      LogCropper.new(foreman_log_file, "#{log_location}/#{time_prefix}foreman.fail.log", true),
      LogCropper.new(foreman_log_file, "#{log_location}/#{time_prefix}foreman.log")
    ]
  end
  @logger
end



def hammer(*args)

  if (args[-1].is_a? Hash)
    options = args.pop
    options.collect do |key, value|
      args << "--#{key.to_s.gsub('_', '-')}"
      args << "#{value}"
    end
  end

  #avoid passing nil values
  args = args.map{|a| a.to_s}

  @command_cnt ||= 0
  @command_cnt += 1

  result = CommandResult.new

  original_args = args.clone
  original_args.unshift("hammer")

  args.unshift(ENV['HT_HAMMER_CMD'] || "hammer")

  logger.log_before_command(original_args.join(" "), @command_cnt, current_section)

  status = Open4.popen4(*args) do |pid, stdin, stdout, stderr|
    result.stdout = stdout.readlines.join("")
    result.stderr = stderr.readlines.join("")
  end
  result.code = status.exitstatus.to_i

  logger.log_command(original_args.join(" "), @command_cnt, result, current_section)

  cmd_stats.add_test(result.ok?)
  return result
end

def current_section
  @current_section ||= []
  @current_section
end

def section(name, &block)
  current_section << name

  logger.log_section(current_section)
  yield
  current_section.pop
end

def test(desc, &block)
  result = yield
  stats.add_test(result)
  logger.log_test(result, desc, current_section)
end

def simple_test(*args)
  res = hammer *args

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

def test_result(res)
  test "returns ok" do
    res.ok?
  end
end
