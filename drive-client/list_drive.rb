#!/usr/bin/env ruby
# frozen_string_literal: true

require "google/apis/drive_v3"
require "googleauth"
require "webrick"
require "uri"
require "yaml"
require "fileutils"

APPLICATION_NAME = "Drive Folder Lister (Loopback)"
CREDENTIALS_PATH = "credentials.json"   # OAuth client json you downloaded
TOKEN_PATH       = "token.yaml"         # saved refresh token etc.

SCOPE = Google::Apis::DriveV3::AUTH_DRIVE_READONLY

# We'll run a tiny local web server to receive the redirect:
HOST = "127.0.0.1"
PORT = 45871
REDIRECT_PATH = "/oauth2callback"
REDIRECT_URI  = "http://#{HOST}:#{PORT}#{REDIRECT_PATH}"

def load_client_id
  unless File.exist?(CREDENTIALS_PATH)
    abort "Missing #{CREDENTIALS_PATH}. Download OAuth client JSON from Google Cloud Console."
  end
  Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
end

def load_saved_token
  return nil unless File.exist?(TOKEN_PATH)
  YAML.load_file(TOKEN_PATH) # Hash
rescue StandardError
  nil
end

def save_token!(hash)
  FileUtils.mkdir_p(File.dirname(TOKEN_PATH)) if File.dirname(TOKEN_PATH) != "."
  File.write(TOKEN_PATH, hash.to_yaml)
end

def build_oauth_client(client_id_obj)
  # googleauth uses Signet under the hood; we can use it directly for loopback.
  Signet::OAuth2::Client.new(
    client_id: client_id_obj.id,
    client_secret: client_id_obj.secret,
    authorization_uri: "https://accounts.google.com/o/oauth2/auth",
    token_credential_uri: "https://oauth2.googleapis.com/token",
    scope: SCOPE,
    redirect_uri: REDIRECT_URI,
    additional_parameters: {
      "access_type" => "offline", # so we can get a refresh_token
      "prompt" => "consent"       # ensures refresh_token on first auth
    }
  )
end

def get_credentials_via_loopback(oauth_client)
  code = nil
  error = nil

  server = WEBrick::HTTPServer.new(
    BindAddress: HOST,
    Port: PORT,
    Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN),
    AccessLog: []
  )

  server.mount_proc(REDIRECT_PATH) do |req, res|
    code = req.query["code"]
    error = req.query["error"]

    res.status = 200
    res["Content-Type"] = "text/html"
    res.body = <<~HTML
      <html>
        <body>
          <h3>Authorization received.</h3>
          <p>You can close this tab and return to the terminal.</p>
        </body>
      </html>
    HTML

    # shut down after we respond
    Thread.new { server.shutdown }
  end

  auth_url = oauth_client.authorization_uri.to_s

  puts "1) Open this URL in your browser to authorize:"
  puts auth_url
  puts
  puts "2) After approving, your browser will redirect to #{REDIRECT_URI} and this script will continue."

  trap("INT") { server.shutdown }

  # Start server (blocks until shutdown)
  server.start

  raise "OAuth error: #{error}" if error
  raise "No authorization code received." if code.nil? || code.empty?

  oauth_client.code = code
  tokens = oauth_client.fetch_access_token!

  # tokens includes access_token, expires_in, refresh_token (usually on first consent)
  tokens
end

def credentials_from_saved_refresh_token(client_id_obj, saved)
  refresh = saved && saved["refresh_token"]
  return nil if refresh.nil? || refresh.empty?

  Google::Auth::UserRefreshCredentials.new(
    client_id: client_id_obj.id,
    client_secret: client_id_obj.secret,
    scope: SCOPE,
    refresh_token: refresh
  )
end

def authorize
  client_id_obj = load_client_id
  saved = load_saved_token

  creds = credentials_from_saved_refresh_token(client_id_obj, saved)
  return creds if creds

  oauth_client = build_oauth_client(client_id_obj)
  tokens = get_credentials_via_loopback(oauth_client)

  # Persist the refresh_token (that’s what makes future runs “simple”)
  save_token!({
    "refresh_token" => tokens["refresh_token"],
    "obtained_at" => Time.now.utc.iso8601
  })

  credentials_from_saved_refresh_token(client_id_obj, load_saved_token)
end

def list_root_folders(service)
  q = [
    "'root' in parents",
    "mimeType = 'application/vnd.google-apps.folder'",
    "trashed = false"
  ].join(" and ")

  page_token = nil
  loop do
    resp = service.list_files(
      q: q,
      spaces: "drive",
      fields: "nextPageToken, files(id, name)",
      page_token: page_token
    )

    resp.files.each { |f| puts "#{f.name}\t#{f.id}" }

    page_token = resp.next_page_token
    break if page_token.nil?
  end
end

service = Google::Apis::DriveV3::DriveService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

list_root_folders(service)
