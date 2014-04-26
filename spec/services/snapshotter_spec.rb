require 'spec_helper'

describe Snapshotter do
  let(:viewport_width) { 320 }
  let(:user_agent)     { nil }
  let(:outfile)        { nil }
  let(:url)            { 'http://joelencioni.com' }

  let(:service) do
    Snapshotter.new(viewport_width: viewport_width,
                    user_agent:     user_agent,
                    outfile:        outfile,
                    url:            url)
  end

  describe '#take_snapshot!' do
    before do
      Phantomjs.stubs(:run).yields(encoded_output)
    end

    subject { service.take_snapshot! }

    context 'when snapshot script outputs JSON' do
      let(:log)            { 'a free-text log' }
      let(:decoded_output) { { title: rand(1_000).to_s, log: log } }
      let(:encoded_output) { ActiveSupport::JSON.encode(decoded_output) }

      it 'returns the page title' do
        expect(subject[:title]).to eq(decoded_output[:title])
      end

      context 'when the snapshot viewport has a user agent' do
        let(:user_agent) { 'Foo' }

        it 'calls Phantom JS with a user agent' do
          service.expects(:run_phantomjs)
            .with(has_entry(userAgent: user_agent)).once
          subject
        end
      end
    end

    context 'when snapshot script outputs non-JSON' do
      let(:encoded_output) { 'This is not JSON' }

      it 'does not raise an error' do
        expect { subject }.to_not raise_error
      end
    end
  end
end
