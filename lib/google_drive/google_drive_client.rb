require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'google_drive'
require_relative 'google_drive_constants'

module GoogleDrive
  class GoogleDriveClient

    def obtain_session
      client = Google::APIClient.new(
          :application_name => GOOGLE_DRIVE_APPLICATION_NAME,
          :application_version => GOOGLE_DRIVE_APPLICATION_VERSION)

      file_storage = Google::APIClient::FileStorage.new(GOOGLE_DRIVE_CREDENTIALS_FILENAME)
      if file_storage.authorization.nil?
        flow = Google::APIClient::InstalledAppFlow.new(
            :client_id => ENV['GOOGLE_DRIVE_CLIENT_ID'],
            :client_secret => ENV['GOOGLE_DRIVE_CLIENT_SECRET'],
            :scope => %w(
              https://www.googleapis.com/auth/drive
              https://docs.google.com/feeds/
              https://docs.googleusercontent.com/
              https://spreadsheets.google.com/feeds/
            ),
        )
        client.authorization = flow.authorize(file_storage)
      else
        client.authorization = file_storage.authorization
      end

      access_token = client.authorization.access_token
      GoogleDrive.login_with_oauth(access_token)
    end

    def obtain_spreadsheet_value(session, spreadsheet_id, worksheet_number, cell_id)
      worksheet = session.spreadsheet_by_key(spreadsheet_id).worksheets[worksheet_number]
      worksheet[cell_id]
    end
  end
end