module Gmailer
  class GmailClient
    def initialize
      begin
        secret = YAML.load_file("./config/secret.yml")
        @gmail = Gmail.connect(:xoauth2, secret['email'], secret['access_token'])
        raise "Cannot log_in to gmail. email or access-token is incorrect." unless @gmail.logged_in?
      rescue => e
        puts e.message
        exit 1
      end
    end

    def send_email(to, subject, text)
      return if to.nil? || subject.nil? || text.nil?
      email = @gmail.compose do
        to to
        subject subject
        body text
      end
      @gmail.deliver(email)
    end
  end
end
