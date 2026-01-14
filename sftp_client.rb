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

      opts.on('-p', '--matching-patterns=PATTERNS') do |patterns|
        # Split by & to get AND groups, then split each group by | to get OR patterns
        @matching_patterns = patterns.split('&').map do |group|
          group.split('|').map { |pattern| Regexp.new(pattern) }
        end
      end

      opts.on('-l', '--local-dir=LOCAL_DIR') do |local_dir|
        @local_dir = local_dir
      end
    end

    parser.parse!
    process_cli_errors!

    @timestamp ||= DateTime.now - 1.day
    @action ||= 'print'
  end

  def run
    unless @action == 'upload'
      files = list_files_newer_than(timestamp:)
      files = filter_by_patterns(files) if @matching_patterns&.any?
    end

    case @action
    when 'print'
      files.each { |file| puts file }
    when 'download'
      download_all files
    when 'upload'
      upload_all_files
    end
  end

  private

  def upload_all_files
    files = Dir.children(@local_dir).select do |name|
      File.file?(File.join(@local_dir, name))
    end

    files = filter_by_patterns(files) if @matching_patterns&.any?

    files.each_slice(MAX_SIMULTANEOUS_DOWNLOADS) do |batch|
      async_sessions = []
      batch.each do |name|
        local_path = File.join(@local_dir, name)
        remote_path = "#{@remote_dir}/#{name}"
        puts "Starting upload of #{local_path} to #{remote_path}"
        async_sessions << session.upload(local_path, remote_path)
      end

      async_sessions.each do |upload_operation|
        upload_operation.wait
      end
    end
  end

  def process_cli_errors!
    error = false
    if @hostname.nil?
      $stderr.puts "No sftp hostname provided."
      error = true
    end

    unless @action.nil? || ['print', 'upload', 'download'].include?(@action)
      $stderr.puts "No valid action provided."
      error = true
    end

    if @remote_dir.nil?
      $stderr.puts "No sftp directory provided."
      error = true
    end

    if @action != 'print' && !@local_dir.nil? && !Dir.exist?(@local_dir)
      $stderr.puts "Local directory '#{@local_dir}' does not exist for upload/download action."
      error = true
    end

    exit -1 if error
  end

  def session
    (user_name, password) = environment_credentials
    @session ||= open_session(@hostname, user_name, password)
  end

  def list_files_newer_than(timestamp:)
    list_files_compared_to(remote_listings, timestamp, comparison: :newer).map do |filepath|
      filepath
    end
  end

  def list_files_compared_to(listings, last_day, comparison: :older)
    ans = listings.filter do |listing|
      listing.file? && mtime_compared_passes?(listing, last_day, comparison:)
    end

    ans.map(&:name)
  end

  def mtime_compared_passes?(file, limit, comparison:)
    filetime = Time.at(file.attributes.mtime).to_datetime
    comparison == :older ? filetime < limit : filetime >= limit
  end

  def remote_listings
    @remote_listings ||= all_remote_directory_contents
  end

  def filter_by_patterns(filenames)
    filenames.select { |filename| matches_patterns?(filename) }
  end

  def matches_patterns?(filename)
    # All groups must match (AND), where each group passes if any pattern matches (OR)
    @matching_patterns.all? do |group|
      group.any? { |pattern| filename.match?(pattern) }
    end
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

  def download_all(list)
    list.each_slice(MAX_SIMULTANEOUS_DOWNLOADS) do |batch|
      async_sessions = []
      batch.each do |name|
        local_path = @local_dir ? File.join(@local_dir, name) : name
        next if File.exist?(local_path)
        puts "Starting download of #{name} to #{local_path}"
        async_sessions << session.download("#{@remote_dir}/#{name}", local_path)
      end

      async_sessions.each do |download_operation|
        download_operation.wait
      end
    end
  end
end

# ruby sftp_client.rb --hostname canopyanalytics.files.com --remote-dir amcllc-staging-2 --newer-than 20260105:0000
#                     --action <print|download> --local-dir /path/to/local/dir --matching-patterns 'a|b|c&d|e' 

sftp_client = SFTPClient.new
sftp_client.run
