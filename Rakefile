require "./lib/gmailer.rb"

desc "Usage : params=/file/path template=/file/path dry_run=0 bundle exec rake bulk_send"
task :bulk_send do
  # when dry_run=0, send emails; otherwise not send emails
  dry_run = ENV['dry_run'].nil? || ENV['dry_run'].to_i != 0
  if ENV["params"].nil? || ENV["template"].nil?
    puts "required parameters are missing"
    exit 1
  end

  Gmailer::BulkSender.bulk_send(ENV['params'], ENV['template'], dry_run)
end
