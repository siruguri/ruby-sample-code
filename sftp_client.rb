require 'pry'
require 'net/sftp'
require 'date'
require 'active_support/core_ext/numeric/time'
require 'optparse'

class SFTPClient
  attr_reader :session, :timestamp

  MAX_SIMULTANEOUS_DOWNLOADS = 10

  def initialize
    options = {}
    parser = OptionParser.new do |opts|
      opts.on('-h', '--hostname=HOSTNAME') do |hostname|
        @hostname = hostname
      end

      opts.on('-d', '--remote-dir=REMOTE_DIR') do |remote_dir|
        @remote_dir = remote_dir
      end

      opts.on('-m', '--newer-than=TIMESTAMP') do |timestamp|
        @timestamp = DateTime.strptime(timestamp, '%Y%m%d:%H%M')
      end

      opts.on('-a', '--action=ACTION') do |action|
        @action = action
      end
    end

    parser.parse!
    process_cli_errors!

    @timestamp ||= DateTime.now - 1.day
    @action ||= 'print'
  end

  def run
    if @action == 'print'
      list_files_newer_than(timestamp:).each do |file|
        puts file
      end
    end
  end

  private

  def process_cli_errors!
    unless @hostname.present?
      $stderr.puts "No sftp hostname provided."
      exit -1
    end
  end

  def session
    (user_name, password) = environment_credentials
    @session ||= open_session(@hostname, user_name, password)
  end

  def list_files_newer_than(timestamp:)
    return if @remote_dir.nil?

    list_files_compared_to(timestamp, comparison: :newer).map do |filepath|
      filepath
    end
  end

  def list_files_compared_to(last_day, comparison: :older)
    listings = all_remote_directory_contents
    ans = listings.filter do |listing|
      listing.file? && mtime_compared_passes?(listing, last_day, comparison:)
    end

    ans.map(&:name)
  end

  def mtime_compared_passes?(file, limit, comparison:)
    filetime = Time.at(file.attributes.mtime).to_datetime
    comparison == :older ? filetime < limit : filetime >= limit
  end

  def environment_credentials
    user_name = ENV['sftp_username'] ||
                raise(Integrations::Exceptions::BadCredentialsException.new('SFTP username must be set'))
    password = ENV['sftp_password'] ||
               raise(Integrations::Exceptions::BadCredentialsException.new('SFTP password must be set'))
    [user_name, password]
  end

  def open_session(host_name, user_name, password)
    puts("Attempting SFTP connection to #{host_name}")
    session = nil
    begin
      session = Net::SFTP.start(host_name, user_name, password: password, non_interactive: true)
    rescue Net::SSH::AuthenticationFailed
      raise(Integrations::Exceptions::BadCredentialsException.new('Username or password rejected by SFTP server'))
    end
    session
  end

  def all_remote_directory_contents
    session.dir.entries(@remote_dir)
  end

  def download_all
    async_sessions = []
    @available_list.each do |name|
      async_sessions << @client.session.download(name, name)
    end

    async_sessions.each do |download_operation|
      download_operation.wait
    end
  end
end

# ruby sftp_client.rb --hostname canopyanalytics.files.com --remote-dir amcllc-staging-2 --newer-than 20260105:0000 --action print

sftp_client = SFTPClient.new
sftp_client.run

