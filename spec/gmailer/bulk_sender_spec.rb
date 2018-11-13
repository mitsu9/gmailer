describe Gmailer::BulkSender do
  let(:params_json) { { 'subject' => 'subject', 'params' => [ { 'email' => 'a@gmail.com', 'name' => 'Aaron' }, { 'email' => 'b@gmail.com', 'name' => 'Barrett' }] } }
  let(:template_file_content) do
    content = <<'EOF'
Mr.<%= params['name']%>
> Hello World!!
EOF
  end

  describe "#bulk_send" do
    let(:param_file_path) { 'dummy_param.yml' }
    let(:template_file_path) { 'dummy_template.erb' }
    let(:dry_run) { true }

    subject { Gmailer::BulkSender.bulk_send(param_file_path, template_file_path, dry_run) }

    context 'invalid params' do
      context 'not exist param file' do
        it do
          allow(File).to receive(:exist?).and_return(false)
          expect{ subject }.to raise_error SystemExit
        end
      end
    end

    context 'valid patams' do
      let(:mocked_file) { double("file", :read => template_file_content)}

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(YAML).to receive(:load_file).and_return(params_json)
        allow(File).to receive(:open).and_return(mocked_file)
        allow(Gmailer::BulkSender).to receive(:dry_run)
        allow(Gmailer::BulkSender).to receive(:execute)
      end

      context 'dry_run' do
        let(:dry_run) { true }
        it 'calls dry_run' do
          subject
          expect(Gmailer::BulkSender).to have_received(:dry_run)
        end
      end

      context 'not dry_run' do
        let(:dry_run) { false }
        it 'calls execute' do
          subject
          expect(Gmailer::BulkSender).to have_received(:execute)
        end
      end
    end
  end

  context '#create_emails' do
    let(:erb) { ERB.new(template_file_content, nil, '-%') }
    let(:params) { params_json['params'] }
    let(:expected_array) do
      [
        { email: "a@gmail.com", text: "Mr.Aaron\n> Hello World!!\n"},
        { email: "b@gmail.com", text: "Mr.Barrett\n> Hello World!!\n"}
      ]
    end

    subject { Gmailer::BulkSender.send(:create_emails, erb, params) }

    it { is_expected.to eq(expected_array) }
  end
end
