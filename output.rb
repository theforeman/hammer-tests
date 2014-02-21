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
