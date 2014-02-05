require 'spec_helper'

describe Snapshotter do
  let(:snapshot) { create(:snapshot, :pending) }
  subject        { Snapshotter.new(snapshot) }

  describe '#take_snapshot!' do
    before do
      Phantomjs.stubs(:run).yields(encoded_output)
      prc = Proc.new do |snapshot, file|
        # Since we're not actually taking snapshots, we need to fake the image.
        File.open("#{Rails.root}/spec/sample_snapshot.png") do |f|
          snapshot.image = f
        end
      end
      subject.stubs(:save_file_to_snapshot).with(&prc)
    end

    context 'when snapshot script outputs JSON' do
      let(:decoded_output) { { title: rand(1_000).to_s } }
      let(:encoded_output) { ActiveSupport::JSON.encode(decoded_output) }

      it 'saves the title to the snapshot' do
        expect { subject.take_snapshot! }
          .to change { snapshot.reload.title }
          .to(decoded_output[:title])
      end

      it 'saves an image on the snapshot object' do
        expect { subject.take_snapshot! }
          .to change { snapshot.reload.image.path }
      end
    end

    context 'when snapshot script outputs non-JSON' do
      let(:encoded_output) { 'This is not JSON' }
      it 'raises an error with the script output' do
        expect { subject.take_snapshot! }.to raise_error(encoded_output)
      end
    end
  end
end
