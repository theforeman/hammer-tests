require 'csv'

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


class CsvOutput < Output

  def initialize(output)
    parse(output)
  end

  def column_titles
    @titles || []
  end

  def has_column?(name)
    column_titles.include?(name.upcase)
  end

  def column(name)
    idx = column_titles.index(name)
    return [] if idx.nil?
    @rows.map do |row|
      row[idx]
    end
  end

  private

  def parse(output)
    @titles = nil
    @rows = []
    CSV.parse(output) do |row|
      if @titles.nil?
        @titles = row
      else
        @rows << row
      end
    end
  end

end

class SimpleCsvOutput < CsvOutput

  def column(name)
    super(name)[0]
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

  def contains_line?(cells)
    regexp = line_regexp(cells)
    lines.any? { |l| regexp =~ l }
  end

  protected
  def line_regexp(expected_cells)
    re = expected_cells.map do |column|
      if column.nil?
        '[^\|]*'
      elsif column.is_a?(Regexp)
        "[ ]*#{column.source}[ ]*"
      else
        "[ ]*#{Regexp.quote(column.to_s)}[ ]*"
      end
    end.join('\|').gsub(/(\[\ \]\*)+/, '[ ]*')
    Regexp.new(re)
  end
end

class ShowOutput < Output
  def initialize(output)
    parse(output)
    @output = output
  end

  def has_column?(name)
    column_titles.include?(name)
  end

  def column_titles
    @content.keys
  end

  def column(name)
    @content[name]
  end

  def matches?(columns)
    @output.split("\n").each do |line|
      return true if columns.empty?
      matcher = columns.shift
      if matcher.nil?
        next
      elsif matcher.is_a?(Regexp)
        return false, "Line '#{line}' didn't match #{matcher.source}" if line !~ matcher
      elsif matcher.is_a?(Array)
        return false, "Line '#{line}' didn't match #{line_regexp(matcher).source}" if line_regexp(matcher) !~ line
      else
        return false, "Line '#{line}' didn't equal #{matcher}" if line != matcher
      end
    end
    true
  end

  protected

  def line_regexp(items)
    if items.empty?
      Regexp.new('.*')
    else
      re = items.map do |i|
        if i.is_a?(Regexp)
          "[ ]*#{i.source}[ ]*"
        else
          "[ ]*#{Regexp.quote(i.to_s)}[ ]*"
        end
      end.join('').gsub(/(\[\ \]\*)+/, '[ ]*')
      Regexp.new(re)
    end
  end

  def parse(output)
    @content = {}
    last_title = nil

    output.split("\n").each do |line|
      if line.start_with?(" ")
        @content[last_title] << "\n" unless @content[last_title].empty?
        @content[last_title] << line.strip
      else
        title, *rest = line.split(":")
        value = rest.join(":")
        last_title = title.to_s.strip
        @content[last_title] = value.strip
      end
    end
  end
end
