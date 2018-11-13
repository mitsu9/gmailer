require "rake"

describe "Rakefile" do
  before(:all) do
    Rake.application.load_rakefile
  end

  describe "bulk_send" do
    subject { capture(:stdout){ Rake.application[task_name].execute() } }
    let(:task_name) { "bulk_send" }
    let(:params) { "dummy_param.yml" }
    let(:template) { "dummy_template.erb" }
    let(:base_env) { { "params" => params, "template" => template, "dry_run" => 0 } }

    context "invalid case" do
      before do
        env = base_env
        env.delete("params")
        stub_const "ENV", ENV.to_h.merge(env)
      end
      it { expect{ subject }.to raise_error SystemExit }
    end

    context "valid case" do
      context "with dry_run" do
        before do
          stub_const "ENV", ENV.to_h.merge(base_env)
          allow(Gmailer::BulkSender).to receive(:bulk_send)
        end

        it 'calls BulkSender.bulk_send with dry_run = false' do
          subject
          expect(Gmailer::BulkSender).to have_received(:bulk_send).with(params, template, false)
        end
      end

      context "without dry_run" do
        before do
          env = base_env
          env.delete("dry_run")
          stub_const "ENV", ENV.to_h.merge(base_env)
          allow(Gmailer::BulkSender).to receive(:bulk_send)
        end

        it 'calls BulkSender.bulk_send with dry_run = true' do
          subject
          expect(Gmailer::BulkSender).to have_received(:bulk_send).with(params, template, true)
        end
      end
    end
  end
end
