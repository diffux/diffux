require 'spec_helper'

describe SnapshotterWorker do
  describe '#perform' do
    let(:service) { described_class.new }
    subject       { service.perform(snapshot_id) }

    context 'when the snapshot does not exist' do
      let(:snapshot_id) { 0 }

      it 'does not raise an error' do
        expect { subject }.to_not raise_error
      end
    end

    context 'when the snapshot exists' do
      let(:snapshot)    { create(:snapshot, :pending) }
      let(:snapshot_id) { snapshot.id }
      let(:log)         { 'a free-text log' }
      let(:title)       { 'Page title' }

      before do
        Diffux::Snapshotter.any_instance.expects(:take_snapshot!)
          .returns(title: 'Page title',
                   log:    log).once

        prc = proc do |snapshot, file|
          # Since we're not actually taking snapshots, we need to fake the
          # image.
          File.open("#{Rails.root}/spec/sample_snapshot.png") do |f|
            snapshot.image = f
          end
        end
        service.stubs(:save_file_to_snapshot).with(&prc)
      end

      it 'saves the title to the snapshot' do
        expect { subject }.to change { snapshot.reload.title }.to(title)
      end

      it 'saves an image on the snapshot object' do
        expect { subject }.to change { snapshot.reload.image.path }
      end

      it 'saves the log to the snapshot' do
        expect { subject }.to change { snapshot.reload.log }.to(log)
      end

      context 'when the log is missing' do
        let(:log) { nil }

        it 'does not save a log' do
          expect { subject }.to_not change { snapshot.reload.log }
        end
      end
    end
  end
end
