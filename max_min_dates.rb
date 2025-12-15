#!/usr/bin/env ruby
require 'csv'
require 'date'
require 'optparse'

class YardiMaxMin
  attr_reader :file_path

  def initialize(file_path)
    # 1) Read file path from ARGV
    @file_path = file_path

    # Target columns
    @date_columns = ["InvoiceDate", "PostDate", "CheckDate"]

    # 3) Track only running min/max per column (no big arrays)
    @stats = {}
    @date_columns.each { |c| @stats[c] = { min: nil, max: nil } }
  end

  def run(mesg)
    send mesg
    results report_name: mesg
  end

  # NEW: find rows where CheckDate is blank AND InvoiceDate > PostDate
  # Returns an array of hashes: { line:, invoice_date:, post_date:, row: }
  def offenders
    @offenders = []
    CSV.foreach(file_path, headers: true).with_index(2) do |row, csv_line_number|
      # blank CheckDate?
      check_blank = row["CheckDate"].nil? || row["CheckDate"].strip.empty?
      payment_status = row['PaymentStatus']
      next unless check_blank && payment_status != 'Paid'

      id = row["ID"]
      inv_raw  = row["InvoiceDate"]
      post_raw = row["PostDate"]
      next if inv_raw.nil? || inv_raw.strip.empty? || post_raw.nil? || post_raw.strip.empty?

      begin
        inv_dt  = DateTime.strptime(inv_raw.strip,  "%b %e %Y %I:%M%p")
        post_dt = DateTime.strptime(post_raw.strip, "%b %e %Y %I:%M%p")
      rescue ArgumentError
        warn "Skipping row #{csv_line_number}: unparsable date(s) InvoiceDate='#{inv_raw}', PostDate='#{post_raw}'"
        next
      end

      if inv_dt > post_dt
        @offenders << {
          id: id,
          line: csv_line_number,        # includes header, so data starts at 2
          invoice_date: inv_dt,
          post_date: post_dt,
          row: row.to_h
        }
      end
    end

    @offenders
  end

  def max_min
    CSV.foreach(file_path, headers: true) do |row|
      @date_columns.each do |col|
        raw = row[col]
        next if raw.nil? || raw.strip.empty?

        begin
          set_max_min(raw, col)
        rescue ArgumentError
          warn "Skipping unparsable date '#{raw}' in column #{col}"
        end
      end
    end
  end

  def results(report_name: :max_min)
    case report_name
    when :max_min
      @date_columns.each do |col|
        min = @stats[col][:min]
        max = @stats[col][:max]
        if min.nil? || max.nil?
          puts "#{col}: No valid dates found."
        else
          puts "#{col}:"
          puts "  Earliest: #{min}"
          puts "  Latest:   #{max}"
        end
      end

    when :offenders
      puts @offenders.size
      CSV.open('/Users/sameer/tmp/offenders.csv', 'w') do |csv|
        10.times do |index|
          csv << @offenders[index][:row].values
        end
      end
    end
  end

  private

  def set_max_min(raw, col)
    # 2) Only strip leading/trailing spaces; do NOT normalize internal spacing
    s = raw.strip

    dt = DateTime.strptime(s, "%b %e %Y %I:%M%p")
    # Update running min/max
    @stats[col][:min] = dt if @stats[col][:min].nil? || dt < @stats[col][:min]
    @stats[col][:max] = dt if @stats[col][:max].nil? || dt > @stats[col][:max]
  end
end

options = { report_type: :max_min }
parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby #{File.basename($0)} [options] <path/to/file.csv>"

  opts.on("--report-type TYPE", [:max_min, :offenders],
          "Report type: max_min or offenders (default: max_min)") do |r|
    options[:report_type] = r
  end
end

parser.order!(ARGV)
file_path = ARGV.shift or abort(parser.to_s)

# -------- Main --------
yardi = YardiMaxMin.new(file_path)
yardi.run(options[:report_type])
