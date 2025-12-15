#!/usr/bin/env ruby
require 'json'

# Usage: ruby parse_jsonl.rb path/to/file.jsonl
filepath = ARGV[0]
abort "Please provide a .jsonl file path." unless filepath && File.exist?(filepath)

result = []

File.foreach(filepath) do |line|
  next if line.strip.empty?

  begin
    obj = JSON.parse(line)
  rescue JSON::ParserError => e
    warn "Skipping invalid JSON line: #{e}"
    next
  end

  # --- Merge Strategy ---
  # If each line is an object, you can:
  #   - merge keys
  #   - collect items in arrays
  #   - or build by ID
  #
  # Here we simply merge keys into a big hash.
  # Adjust this depending on your file’s structure:
  result << obj
end

result.each do |list|
  #puts list['request']['context']
  puts list['request']['url']
  #puts list['request'].keys
end

