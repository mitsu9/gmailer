describe Gmailer::GmailClient do
  let(:secret_file_content) { 'empty_file' }

  describe "#initialize" do
    let(:mocked_gmail) { double("gmail") }

    subject { capture(:stdout){ Gmailer::GmailClient.new } }

    context 'invalid params' do
      context 'not exist ./config/secret.yml' do
        before do
          allow(File).to receive(:open).and_raise('No such file or directory')
        end
        it { expect{ subject }.to raise_error SystemExit }
      end

      context 'incorrect email or access_token' do
        before do
          allow(File).to receive(:open).and_return(secret_file_content)
          allow(Gmail).to receive(:connect).and_return(mocked_gmail)
          allow(mocked_gmail).to receive(:logged_in?).and_return(false)
        end
        it { expect{ subject }.to raise_error SystemExit }
      end
    end

    context 'valid params' do
      before do
        allow(File).to receive(:open).and_return(secret_file_content)
        allow(Gmail).to receive(:connect).and_return(mocked_gmail)
        allow(mocked_gmail).to receive(:logged_in?).and_return(true)
      end
      it { expect{ subject }.not_to raise_error }
    end
  end

  describe ".send_email" do
    let(:mocked_gmail) { double("gmail", :logged_in? => true) }
    let(:email) { double("email") }

    let(:to) { "to_email" }
    let(:subject) { "subject" }
    let(:text) { "text" }

    before do
      # For #initialize
      allow(File).to receive(:open).and_return(secret_file_content)
      allow(Gmail).to receive(:connect).and_return(mocked_gmail)
      # For .send_email
      allow(mocked_gmail).to receive(:compose).and_return(email)
      allow(mocked_gmail).to receive(:deliver)
    end

    context 'invalid params' do
      let(:to) { nil }
      it do
        Gmailer::GmailClient.new.send_email(to, subject, text)
        expect(mocked_gmail).not_to have_received(:compose)
      end
    end

    context 'valid params' do
      it 'calls deliver method' do
        Gmailer::GmailClient.new.send_email(to, subject, text)
        expect(mocked_gmail).to have_received(:deliver).with(email)
      end
    end
  end
end
