module Gmailer
  class BulkSender
    class << self
      def bulk_send(param_file, template_file, dry_run)
        unless File.exist?(param_file) && File.exist?(template_file)
          puts 'param_file or template_file does not exist.'
          exit 1
        end

        params = YAML.load_file(param_file)
        template_string = File.open(template_file).read
        erb = ERB.new(template_string, nil, '-%')

        subject = params['subject']
        emails = create_emails(erb, params['params'])

        if dry_run
          dry_run(subject, emails)
        else
          execute(subject, emails)
        end
      end

      private

      def create_emails(erb, all_params)
        all_params.each_with_object([]) do |params, ary|
          email = params['email']
          text = erb.result(binding)
          ary << { email: email, text: text}
        end
      end

      def dry_run(subject, emails)
        puts "Send email N = #{emails.length}"
        email_info = emails.first
        puts "------------------------------"
        puts "TO     : #{email_info[:email]}"
        puts "SUBJECT: #{subject}"
        puts "TEXT:"
        puts "#{email_info[:text]}"
        puts "------------------------------"
      end

      def execute(subject, emails)
        puts "Subject: #{subject}"
        puts "Destinations: N = #{emails.length}"
        emails.map { |h| h[:email] }.each { |email| puts "- #{email}" }
        puts "It's OK? (yes/N)"
        confirm = STDIN.gets.chomp
        if confirm != "yes"
          puts "Aborted."
          exit 1
        end
        client = Gmailer::GmailClient.new
        emails.each do |email_info|
          client.send_email(email_info[:email], subject, email_info[:text])
        end
        puts "Finish sending emails!!"
      end
    end
  end
end
