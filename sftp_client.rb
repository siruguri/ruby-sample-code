require 'net/sftp'
require 'date'
require 'active_support/core_ext/numeric/time'
require 'optparse'

class SFTPClient
  attr_reader :session, :filecount_threshold

  MAX_SIMULTANEOUS_DOWNLOADS = 10

  def initialize(host_name:, remote_dir: nil, local_dir: nil, logger: nil, expected_files: nil, filecount_threshold: -1)
    @remote_dir = remote_dir
    @local_dir = local_dir
    @expected_files = expected_files
    @filecount_threshold = filecount_threshold
    @logger = logger

    (user_name, password) = environment_credentials
    @session = open_session(host_name, user_name, password)
  end

  def list_files_newer_than(timestamp:)
    return if @remote_dir.nil?

    list_files_compared_to(timestamp, comparison: :newer).map do |filepath|
      filepath
    end
  end

  private

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
    user_name = ENV['exavault_username'] ||
                raise(Integrations::Exceptions::BadCredentialsException.new('exavault_username must be set'))
    password = ENV['exavault_password'] ||
               raise(Integrations::Exceptions::BadCredentialsException.new('exavault_password must be set'))
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
    @session.dir.entries(@remote_dir)
  end
end

class Confirmer
  def initialize
    options = {}
    parser = OptionParser.new do |opts|
      opts.on('-s', '--subdomain=SUBDOMAIN') do |subd|
        @subdomain = subd
      end

      opts.on('-h', '--hostname=HOSTNAME') do |hostname|
        @hostname = hostname
      end

      opts.on('-d', '--remote-dir=REMOTE_DIR') do |remote_dir|
        @remote_dir = remote_dir
      end

      opts.on('-m', '--newer-than=TIMESTAMP') do |timestamp|
        @timestamp = DateTime.strptime(timestamp, '%Y%m%d:%H%M')
      end
    end

    parser.parse!

    @timestamp ||= DateTime.now - 1.day
    @client = SFTPClient.new(host_name: @hostname, remote_dir: @remote_dir)

    @organization = Organization.find_by(subdomain: @subdomain)
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

  def show_on_sftp
    @available_list = @client.list_files_newer_than(timestamp: @timestamp)
    @available_list.each do |name|
      puts name
    end
  end

  def compare
    expected_codenames = @organization.unsafe_all_active_communities.
                           pluck(:codename).sort

    known_codenames = @available_list.select { |name| name =~ /LEASES/ }
                        .map { |name| name.gsub(/_.*/, '') }.sort

    puts expected_codenames - known_codenames
  end
end

#Confirmer.new(ARGV[0], ARGV[1], ARGV[2]).compare

# hostname, remote dir, subdomain (for example:
#           ruby sftp_client.rb --hostname canopyanalytics.files.com --remote-dir amcllc-staging-2 --subdomain amcllc
# )

sftp_client = Confirmer.new()
sftp_client.show_on_sftp
sftp_client.download_all
