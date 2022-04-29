require 'csv'
require 'pry'

class Splitter
  attr_reader :if_condition, :output_position, :data_builder, :invoice_list

  def initialize(filepath, output_position, if_condition: nil, data_builder: nil, arguments: [])
    # which field to output
    @filepath = filepath
    @output_position = output_position.to_i
    @if_condition = if_condition
    @data_builder = data_builder
    @_arguments = arguments
    @output_lines = []
  end

  def split
    CSV.foreach(@filepath) do |fields|
      fs = fields.map { |t| t&.strip }
      if if_condition.nil? || method(if_condition).call(fs)
        if output_position == -1
          @output_lines << fs
        else
          if data_builder
            method(data_builder).call fs
          else
            puts fs[output_position]
          end
        end
      end
    end

    puts(CSV.generate do |csv|
      @output_lines.each { |l| csv << l }
    end)
  end

  private
  def arguments(position)
    @_arguments[position]
  end

  def more_recent_than(fields)
    begin
      d = DateTime.strptime(fields[5].to_s, '%b %d %Y %H:%M%p').to_date
    rescue Date::Error
      return false
    end

    d >= cutoff_date
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

  def expense_in_ledger_account(fields)
    community_id = fields[4]
    ledger_id = fields[5]
    postdate = fields[13]

    community_id == arguments(0) && ledger_id == arguments(1) && !(postdate =~ /#{period_regex}/).nil?
  end

  def period_regex
    @_pe ||= Date.parse(arguments(2)).strftime('%b\s+1 %Y')
  end

  def is_mri_rnt_last_two_days(fields)
    fields[1] == 'A02' && (fields[3] == yesterday || fields[3] == day_before)
  end

  def count_invoice_ledger_pairs(fields)
    @pair_hash ||= {}
    @invoice_list ||= Hash.new { |a, b| a[b] = [] }

    if !@pair_hash[[fields[0], fields[5]]]
      @pair_hash[[fields[0], fields[5]]] = 1
      @invoice_list[fields[0]] << fields[5]
    end
  end
end

if ARGV.size < 3
  puts "Help: provide filename, field position (-1 for whole line) to output, and if condition method name"
  exit 1
end

#Splitter.new(ARGV[0], ARGV[1], if_condition: :is_mri_rnt_last_two_days).split
s = Splitter.new(ARGV[0], ARGV[1], if_condition: ARGV[2], data_builder: :count_invoice_ledger_pairs, arguments: ARGV[3..-1])
s.split
