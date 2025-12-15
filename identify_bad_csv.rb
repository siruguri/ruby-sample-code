#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"

if ARGV.empty?
  warn "Usage: ruby detect_bad_csv.rb path/to/file.csv"
  exit 1
end

path = ARGV[0]

last_good_row = nil
last_good_line_number = nil

begin
  CSV.foreach(path) do |row|
    last_good_row = row
    last_good_line_number = $.  # $. is the current line number in the file
  end

  puts "No malformed CSV found."
  exit 0
rescue CSV::MalformedCSVError => e
  # Try multiple ways to get the error line number
  error_line_number =
    if e.respond_to?(:line_number) && e.line_number
      e.line_number
    elsif e.message =~ /line (\d+)/
      Regexp.last_match(1).to_i
    else
      $. # fallback: current line number
    end

  bad_line = nil
  prev_line = nil

  File.foreach(path).with_index(1) do |line, lineno|
    prev_line = line.chomp if lineno == error_line_number - 1
    if lineno == error_line_number
      bad_line = line.chomp
      break
    end
  end

  puts "==== CSV Parse Error Detected ===="
  puts "Error message: #{e.message}"
  puts

  if last_good_line_number
    puts "Last valid line number: #{last_good_line_number}"
    puts "Last valid row: #{last_good_row.inspect}"
  else
    puts "No valid rows parsed before the error."
  end

  puts
  puts "Invalid line number: #{error_line_number}"
  puts "Invalid line content:"
  puts bad_line.inspect
  puts

  # Analyze the bad line for a 'value after quoted field' situation
  def find_unexpected_after_quote(line, col_sep: ",", quote_char: '"')
    state = :start # :start, :unquoted, :in_quotes, :after_quote

    i = 0
    while i < line.length
      ch = line[i]

      case state
      when :start, :unquoted
        if ch == quote_char
          state = :in_quotes
        elsif ch == col_sep
          state = :start
        else
          state = :unquoted
        end
      when :in_quotes
        if ch == quote_char
          # Could be escaped quote ("")
          if line[i + 1] == quote_char
            i += 1 # skip the escaped quote
          else
            state = :after_quote
          end
        end
      when :after_quote
        if ch =~ /[ \t\r]/ # whitespace allowed after closing quote
          # stay in :after_quote
        elsif ch == col_sep
          state = :start
        else
          # This is the “value after quoted field”
          return [i, ch]
        end
      end

      i += 1
    end

    nil
  end

  if bad_line
    pos_info = find_unexpected_after_quote(bad_line)

    if pos_info
      index, char = pos_info
      puts "Detected unexpected character after a quoted field:"
      puts "  Character: #{char.inspect}"
      puts "  0-based index in line: #{index}"
      puts "  1-based column number: #{index + 1}"
      puts

      # Show a small pointer under the offending character
      puts "Line with pointer:"
      puts bad_line
      puts (" " * index) + "^ here"
    else
      puts "Could not automatically detect a specific unexpected character."
      puts "You may need to inspect the line manually, especially around quoted fields."
    end
  else
    puts "Could not read the invalid line from the file."
  end
end
