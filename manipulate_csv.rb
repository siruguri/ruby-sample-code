#!/usr/bin/env ruby

require 'csv'
require 'optparse'

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: manipulate_csv.rb --filepath FILE [options]"

  opts.on("--filepath FILE", "Path to the CSV file") do |v|
    options[:filepath] = v
  end

  opts.on("--exclude", "Exclude lines matching the given patterns") do
    options[:exclude] = true
  end

  opts.on("--matching-field N", Integer, "Field index (1-based) to match patterns against") do |v|
    options[:matching_field] = v
  end

  opts.on("--matching-patterns PATTERNS", "Comma-separated list of regex patterns, e.g. /a*b/,/^1/") do |v|
    options[:matching_patterns] = v
  end

  opts.on("-h", "--help", "Show this help") do
    puts opts
    exit
  end
end.parse!

abort "Error: --filepath is required" unless options[:filepath]
abort "Error: file not found: #{options[:filepath]}" unless File.exist?(options[:filepath])

patterns = []
if options[:matching_patterns]
  options[:matching_patterns].split(",").each do |raw|
    raw = raw.strip
    if raw =~ %r{\A/(.*)/([imx]*)\z}
      flags = 0
      $2.each_char do |f|
        flags |= Regexp::IGNORECASE if f == 'i'
        flags |= Regexp::MULTILINE  if f == 'm'
        flags |= Regexp::EXTENDED   if f == 'x'
      end
      patterns << Regexp.new($1, flags)
    else
      abort "Error: invalid pattern '#{raw}' — must be in /pattern/ format"
    end
  end
end

field_index = options[:matching_field] ? options[:matching_field] - 1 : nil

rows = CSV.read(options[:filepath])

rows.each do |row|
  if field_index && !patterns.empty?
    value = row[field_index].to_s
    matched = patterns.any? { |pat| value.match?(pat) }

    if options[:exclude]
      next if matched
    else
      next unless matched
    end
  end

  puts row.to_csv
end
