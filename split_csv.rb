require 'csv'
require 'pry'
require_relative 'cli_reader'

class Splitter
  attr_reader :if_conditions, :output_position, :invoice_list

  def initialize(filepath, arguments: [])
    @filepath = filepath
    @output_lines = []
    @value_counts = Hash.new { |a, b| a[b] = Hash.new(0) }

    cli_reader = CliReader.new(arguments)
    @output_position = cli_reader.parameter_argument('--output', default: 'all')
    @if_conditions = cli_reader.parameter_argument('--method', default: '').split(',')

    @_arguments = cli_reader.parameter_argument('--arguments', default: '').split(',')

    positions = cli_reader.parameter_argument('--input-positions')
    @positions = positions ? positions.split(',').map { |t| t.strip.to_i } : nil
    @unique_position = @positions[0] if @positions&.size == 1

    @header_row = cli_reader.parameter_argument('--header-row-index').to_i
  end

  def split
    row_index = 0
    CSV.foreach(@filepath, liberal_parsing: true) do |fields|
      fs = fields.map { |t| t&.strip }
      parse_headers(fields) if row_index == @header_row
      if if_conditions.empty? || if_conditions.all? { |condition| true == check_condition(condition, @_arguments, fs) }
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

      row_index += 1
    end

    if @output_lines.size > 0
      puts(CSV.generate do |csv|
             @output_lines.each { |l| csv << l }
           end)
    end

    output_value_counts if if_conditions.include?('value_counts')
  end

  private

  def check_condition(method_signature, argument_signatures, all_fields)
    (condition_name, check_column) = method_signature.split(':')
    check_column = check_column.to_i

    args = argument_signatures.map { |sig| sig.split(':') }
    argument = args.find { |pair| pair[0] == condition_name }
    if argument.nil?
      raise "#{condition_name} has no arguments to use."
    end

    argument = argument[1]
    send(condition_name.to_sym, all_fields[check_column], argument)
  end

  def header_label_for(position)
    @_header_labels[position]
  end

  def parse_headers(fields)
    @_header_labels ||= {}
    fields.each_with_index do |value, index|
      @_header_labels[index] = value
    end
  end

  def output_value_counts
    @value_counts.each do |position, tags|
      puts header_label_for(position)
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

  def is_time_equal(check_this_column, check_against)
    d = get_a_date(check_this_column)
    !!d && d == cutoff_date(check_against)
  end

  def is_more_recent_than(check_this_column, check_against)
    d = get_a_date(check_this_column)
    !!d && d >= cutoff_date(check_against)
  end

  def get_a_date(string)
    begin
      d = tz_date_field(string)
    rescue Date::Error
      begin
        d = long_date_field(string)
      rescue Date::Error
        false
      end
    end
  end

  def cutoff_date(value)
    @_cds ||= {}
    @_cds[value] ||= Date.parse value
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

  def is_equal(field_value, condition_argument)
    condition_argument == field_value
  end
end

if ARGV.size < 1
  puts "Help: provide filename at the end, and these arguments:
        --output: comma-sep field positions ('all' for whole line; 'none' for no output)
        --method (you probably want to use is_equal:<n> in most cases; or maybe is_more_recent_than:<n>)
        remaining args depend on the method, for example, for is_equal, you want to supply --arguments <value it's equal to>"
  exit 1
end

s = Splitter.new(ARGV[-1], arguments: ARGV[0..-2])
s.split
