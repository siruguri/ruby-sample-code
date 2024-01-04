require 'csv'
require 'pry'
require_relative 'cli_reader'

class Splitter
  attr_reader :if_condition, :output_position, :invoice_list

  def initialize(filepath, output_position, if_condition: nil, arguments: [])
    # which field to output
    @filepath = filepath
    @output_position = output_position
    @if_condition = if_condition
    @_arguments = arguments
    @output_lines = []
    @value_counts = Hash.new { |a, b| a[b] = Hash.new(0) }

    cli_reader = CliReader.new(arguments)
    positions = cli_reader.parameter_argument('--input-positions')
    @positions = positions.split(',').map { |t| t.strip.to_i }
    @unique_position = @positions[0] if @positions.size == 1
  end

  def split
    CSV.foreach(@filepath, liberal_parsing: true) do |fields|
      fs = fields.map { |t| t&.strip }
      if if_condition.nil? || method(if_condition).call(fs)
        next if @output_position == 'none'
        if output_position == 'all'
          @output_lines << fs
        else
          fs = output_positions.map do |position|
            v = fs[position] =~ /,/ ? "\"#{fs[position]}\"" : fs[position]
          end
          @output_lines << fs
        end
      end
    end

    if @output_lines.size > 0
      puts(CSV.generate do |csv|
             @output_lines.each { |l| csv << l }
           end)
    end

    output_value_counts if if_condition == 'value_counts'
  end

  private

  def output_value_counts
    @value_counts.each do |position, tags|
      puts position
      puts '| '
      tags.sort_by { |k, v| -1 * v }.each do |tag, count|
        puts(sprintf("|- %31s: %d", tag, count))
      end
    end
  end

  def fields_in_position(fs, pos)
    fs[pos.to_i]
  end

  def output_positions
    @output_position.split(',').map { |v| v.to_i }
  end

  def arguments(position)
    @_arguments[position]
  end

  def type_is_vendor(fields)
    fields[2] == 'VendorID'
  end

  def value_in_position(fields, position: nil)
    if position.nil?
      if @unique_position.nil?
        raise 'No input position specified'
      end
      fields[@unique_position]
    else
      fields[position]
    end
  end

  def value_counts(fields)
    if @positions.any? { |position| value_in_position(fields, position: position) == '(No column name)' } ||
       @positions.any? { |position| value_in_position(fields, position: position) =~ /Segment/ }
      return false
    end

    @positions.each do |position|
      @value_counts[position][value_in_position(fields, position: position)] += 1
    end

    true
  end

  def is_yardi_marketrent_more_recent_than(fields)
    is_more_recent_than(fields) && value_in_position(fields) == 'Rent Change'
  end

  def is_more_recent_than(fields)
    begin
      d = tz_date_field(fields_in_position(fields, arguments(1)))
    rescue Date::Error
      return false
    end

    d && d >= cutoff_date
  end

  def cutoff_date
    @_cd ||= Date.parse @_arguments[0]
  end

  def yesterday
    @yest ||= (Date.today - 1.day).strftime('%-d-%b-%Y')
  end

  def day_before
    @dayb ||= (Date.today - 2.day).strftime('%-d-%b-%Y')
  end

  def is_charge(fields)
    fields[23] == 'Invoice'
  end

  def ledger_account_is(fields)
    ledger_account_id = fields[5]
    ledger_account_id == arguments(0)
  end

  def expense_in_period(fields)
    begin
      postdate = long_date_field fields[13]
    rescue
      return
    end

    return false if postdate.nil?
    postdate.year == arguments(0).to_i && postdate.month == arguments(1).to_i
  end

  def yardi_invoices_communities(fields)
    community_id = fields[4]
    community_id.in?(community_id_list)
  end

  def community_id_list
    @cid_list ||= arguments(0).split(',').map(&:strip)
  end

  def yardi_prospect_history(fields)
    date_str = fields[5]
    date = long_date_field date_str

    cond = date && start_date <= date && date <= end_date
    if cond
      cond = cond && (first_contact = fields[8] == '-1')
    end

    cond
  end

  def start_date
    @_sd ||= ordinary_date(arguments(0))
  end

  def end_date
    @_endd ||= ordinary_date(arguments(1))
  end

  def ordinary_date(s)
    Date.strptime(s, '%Y-%m-%d')
  end

  def datetime_field(s)
    return nil if s.blank?
    begin
      return DateTime.strptime(s, '%b %d %Y %H:%M%p')
    rescue Date::Error => e
      return nil
    end
  end

  def long_date_field(s)
    # "Feb 13 2014 12:00AM" -- AKA
    # '%b %d %Y %H:%M%p'
    datetime_field(s)&.to_date
  end

  def tz_date_field(s)
    # "5/13/2012 12:00 AM -07:00" -- AKA
    return nil if s.blank?
    DateTime.strptime(s, '%m/%d/%Y %H:%M %p %z').to_date
  end

  def expense_in_ledger_account(fields)
    community_id = fields[4]
    ledger_id = fields[5]
    postdate = fields[13]

    community_id == arguments(0) && ledger_id == arguments(1) && !(postdate =~ /#{period_regex}/).nil?
  end

  def period_regex
    @_pe ||= Date.parse(arguments(2)).strftime('%b\s+1 %Y')
  end

  def is_rnt_last_two_days(fields)
    fields[1] == @_arguments[0] && (fields[3] == yesterday || fields[3] == day_before)
  end

  def count_invoice_ledger_pairs(fields)
    @pair_hash ||= {}
    @invoice_list ||= Hash.new { |a, b| a[b] = [] }

    if !@pair_hash[[fields[0], fields[5]]]
      @pair_hash[[fields[0], fields[5]]] = 1
      @invoice_list[fields[0]] << fields[5]
    end
  end

  def is_equal(fields)
    arguments(1) == fields[arguments(0).to_i]
  end
end

if ARGV.size < 2
  puts "Help: provide filename, comma-sep field positions ('all' for whole line; 'none' for no output) to output, and optional if condition method name, followed by arguments which are counted from 0 onwards in the code"
  exit 1
end

s = Splitter.new(ARGV[0], ARGV[1], if_condition: ARGV[2], arguments: ARGV[3..-1])
s.split
