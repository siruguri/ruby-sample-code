require 'pry'
require 'csv'

class JoinFiles
  def initialize(file1, file2, key_columns)
    @lines1 = read_file file1
    @lines2 = read_file file2
    @key_columns = key_columns.split(',').map { |t| t.strip.to_i }

    @data = Hash.new { |a, b| a[b] = {} }
  end

  def run
    insert_keys '1', @lines1
    insert_keys '2', @lines2

    puts(show_minus '1', '2')
    puts(show_minus '2', '1')
  end

  private

  def show_minus(db1, db2)
    (@data[db1].keys.select do |k|
       convert(@data[db1][k]) != convert(@data[db2][k])
     end.map { |t| t })
  end

  def convert(value)
    if value =~ /\.$/
      (value.gsub(/,/, '').to_f * 100).to_i
    elsif value =~ /\d+/
      value.to_i
    end
  end

  def insert_keys(db, lines)
    lines.each do |data|
      key = @key_columns.map do |col|
        data[col]
      end

      value = data.each_with_index.select do |val, index|
        !(@key_columns.include?(index))
      end.map { |val, _| val }
      @data[db][key] = value
    end
  end

  def read_file(handle)
    t = []
    CSV.foreach(handle) do |line|
      t << line.map { |t| t&.strip }
    end
    t
  end
end

JoinFiles.new(*ARGV).run
