require_relative '../../app/lib/utilities/s3_manager'
require 'aws-sdk-s3'

region = ENV['AWS_REGION'] || 'us-west-1'
creds_folder = ENV['CREDS_FOLDER'] || '.'

uipath_creds = File.open(File.join(creds_folder, 'uipath_creds.csv'), 'r').readlines.first.chomp.split(',')
report_creds = File.open(File.join(creds_folder, 'sched_reports_creds.csv'), 'r').readlines.first.chomp.split(',')
db_backup_creds = File.open(File.join(creds_folder, 'db_backup_creds.csv'), 'r').readlines.first.chomp.split(',')

creds = Aws::Credentials.new(db_backup_creds[0], db_backup_creds[1])
creds = Aws::Credentials.new(uipath_creds[0], uipath_creds[1]) # bucket us-west-1
creds = Aws::Credentials.new(report_creds[0], report_creds[1])

client = S3Manager.new(credentials: creds,
                       bucket: ARGV[0], region: region)

client.delete_files(older_than_days: ARGV[1]&.to_i || 30)
