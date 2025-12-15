#!/usr/bin/env ruby
# frozen_string_literal: true

require "google/apis/drive_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"

OOB_URI = "urn:ietf:wg:oauth:2.0:oob" # legacy; still works for some setups
APPLICATION_NAME = "Drive Folder Lister"
CREDENTIALS_PATH = "credentials.json" # downloaded from Google Cloud Console
TOKEN_PATH = "token.yaml"

# Minimum scope to list/download files
SCOPE = Google::Apis::DriveV3::AUTH_DRIVE_READONLY

def authorize
  unless File.exist?(CREDENTIALS_PATH)
    abort "Missing #{CREDENTIALS_PATH}. Download OAuth client JSON from Google Cloud Console."
  end

  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)

  user_id = "default"
  credentials = authorizer.get_credentials(user_id)

  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts "Open this URL in your browser and authorize:"
    puts url
    print "Enter the authorization code: "
    code = STDIN.gets&.strip
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id,
      code: code,
      base_url: OOB_URI
    )
  end

  credentials
end

def list_root_folders(service)
  # "My Drive" root is the special folder id 'root'
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

    resp.files.each do |f|
      puts "#{f.name}\t#{f.id}"
    end

    page_token = resp.next_page_token
    break if page_token.nil?
  end
end

service = Google::Apis::DriveV3::DriveService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

list_root_folders(service)
