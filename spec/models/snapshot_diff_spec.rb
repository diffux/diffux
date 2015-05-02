require 'spec_helper'

describe SnapshotDiff do
  let!(:snapshot_diff) { create(:snapshot_diff) }

  describe '#destroy' do
    subject { snapshot_diff.destroy }

    it 'deletes the snapshot_diff' do
      expect { subject }.to change { SnapshotDiff.all.count }.by(-1)
    end

    context 'with a diff cluster' do
      let!(:diff_cluster_id) do
        create(:snapshot_diff_cluster, snapshot_diff: snapshot_diff).id
      end

      it 'cascade-deletes the diff cluster' do
        subject
        expect { SnapshotDiffCluster.find(diff_cluster_id) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
