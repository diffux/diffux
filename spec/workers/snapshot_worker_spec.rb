require 'spec_helper'

describe SnapshotWorker do
  describe '#perform' do
    context 'when the snapshot does not exist' do
      let(:snapshot_id) { 0 }
      it 'does not raise an error' do
        expect { subject.perform(snapshot_id) }.to_not raise_error
      end
    end
  end
end
