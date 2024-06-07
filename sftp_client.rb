require 'pry'
require 'net/sftp'

class Client
  def initialize(host_name:, remote_dir:)
    @remote_dir = remote_dir
    (user_name, password) = environment_credentials
    @session = open_session(host_name, user_name, password)
  end

  def environment_credentials
    user_name = ENV['sftp_username'] || raise
    password = ENV['sftp_password'] || raise
    [user_name, password]
  end

  def all_remote_directory_contents
    @session.dir.entries(@remote_dir)
  end

  def run
    strings = {}
    all_remote_directory_contents.map(&:name).map do |name|
      matches = (/_([^\d_]+)_(\d+)/).match name

      strings[matches[1]] = 1 if matches[2] =~ /20240120/
    end.join("\n")

    list = (required_keys - strings.keys)
    if list.size > 0
      puts list.sort.join("\n")
    else
      puts "No missing files."
    end
  end

  def required_keys
    %w(
    APITraffic
    AcctTree
    Books
    Budget
    Building
    Categories
    CategoryTree
    ChargType
    CommContacts
    CommPropAttributes
    CommonAttributes
    DeletedTrans
    Details
    GLAccounts
    GlobalDetails
    History
    IncomingCall
    IncomingEmail
    IncomingSMS
    Invoice
    Jobs
    Journal
    Ledger
    Memos
    MoveoutReasons
    NonPersonReceipts
    Notes
    Payments
    Prepayments
    Property
    Prospect
    ReceiptsNoCharge
    Register
    RentableItemHistory
    RentableItemTypes
    RentableItemXRef
    RentableItems
    Resident
    Roommate
    ScheduleCharges
    Unit
    UnitEventHistory
    UnitHistory
    UnitType
    Vendor
    Version
    WebRequest
    WorkOrders)
  end

  def open_session(host_name, user_name, password)
    session = nil
    begin
      session = Net::SFTP.start(host_name, user_name, password: password, non_interactive: true)
    rescue Net::SSH::AuthenticationFailed
      raise 'Username or password rejected by SFTP server'
    end
    session
  end
end

Client.new(host_name: 'canopyanalytics.files.com', remote_dir: ARGV[0]).run
