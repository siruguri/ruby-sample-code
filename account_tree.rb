require 'csv'

class FinancialsMismatches
  THRESHOLD_CENTS = 10

  attr_reader :community_code
  def initialize(subdomain, codename, months, directory = '.')
    @organization = Organization.find_by(subdomain: subdomain)
    @community_code = codename
    @community = Community.active_in_group(organization: @organization).where(codename: codename).first
    initialize_dates(months)
    @accounting_tree_code = AccountTree::DefaultAccountingTreeCode.for_organization(@organization)
    @rows = []
    @directory = directory
  end

  def write_report
    period = Date.new(2025, 8, 1)
    period_assistant = DatePickers::SinglePeriod.new(period, period)
    sections(overview_for(period_assistant)).each do |section|
      process_section(section, period)
    end
  end

  private

  def missing_statement_data?(statement)
    statement.nil? || statement.actual.zero? && statement.budget.zero?
  end

  def initialize_dates(months)
    if months.match?(/^\d+$/)
      to = Date.current.beginning_of_month
      from = to - months.to_i.months
    else
      from = to = Date.parse(months)
    end

    @assistant = DatePickers::SinglePeriod.new(from, to)
    @periods = DateServices.all_months([@assistant.from, @assistant.to])
  end

  def build_report
    @periods.each do |period|
      process_period(period)
    end
  end

  def process_period(period)
    period_assistant = DatePickers::SinglePeriod.new(period, period)
    sections(overview_for(period_assistant)).each do |section|
      process_section(section, period)
    end
  end

  def process_section(section, period)
    table = section.table
    table.parent_ledger_accounts.each do |parent_ledger|
      node = table.tree.tree_node_by_ledger(parent_ledger)
      puts node.model.title
      process_parent_ledger(parent_ledger, section.table, period)
    end
  end

  def process_parent_ledger(parent_ledger, table, period)
    table.children_with_data(parent_ledger, period, period).each do |child_ledger|
      process_child_ledger(child_ledger, table, period)
    end
  end

  def process_child_ledger(child_ledger, table, period)
    node = table.tree.tree_node_by_ledger(child_ledger)
    puts "\t#{node.model.title}"
  end

  def calculate_charges_sum(child_ledger, period)
    charges = ::Financials::LedgerCharges.new(
      @community,
      period, period,
      ledgers: [child_ledger],
      financial_communities: [@community.proxy_community || @community],
      account_tree_node: ledger_client_id(child_ledger)
    )
    charges.charge_details.sum(&:amount_cents)
  end

  def build_row(period, child_ledger, statement, charges_sum)
    difference = statement.actual.cents - charges_sum
    sign_flip = (statement.actual.cents + charges_sum).abs < THRESHOLD_CENTS
    [
      community_code,
      period,
      child_ledger.name,
      statement.actual.cents,
      charges_sum,
      difference,
      sign_flip
    ]
  end

  def csv_fullpath
    if @directory
      File.join(@directory, csv_file_name)
    else
      csv_file_name
    end
  end

  def csv_file_name
    "#{@organization.subdomain}_#{@community.codename}_#{@assistant.from}_#{@assistant.to}_financials_mismatches.csv"
  end

  def overview_for(period)
    current_community = @community.proxy_community || @community
    ::Communities::Financials::Overview.new(current_community, period, period, @account, accounting_tree_code: @accounting_tree_code)
  end

  def sections(overview)
    if @organization.yardi? || @organization.access?(Platforms::Features.experimental_account_tree)
      [overview.general]
    else
      [overview.income, overview.expense]
    end
  end

  def ledger_client_id(ledger_or_proxy)
    ledger_or_proxy.is_a?(AccountTree::LedgerAccountProxy) ? ledger_or_proxy.node.id : ledger_or_proxy.codename.presence
  end
end

if __FILE__ == $PROGRAM_NAME
  subdomain, codename, months, directory = ARGV[0..3]
  raise 'Please provide subdomain, codename, and how many months to run' if subdomain.nil? || codename.nil? || months.nil?
  raise 'Please provide a valid number of months (36) or a specific period (2021-01-01)' unless months.match?(/^\d+$|^\d{4}-\d{2}-\d{2}$/)

  FinancialsMismatches.new(subdomain, codename, months, directory).write_report
end
