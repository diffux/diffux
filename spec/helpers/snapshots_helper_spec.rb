require 'spec_helper'

describe SnapshotsHelper do
  describe '#snapshot_status' do
    subject { snapshot_status(snapshot) }

    context 'with an accepted snapshot' do
      let(:snapshot) { build(:snapshot, :accepted) }
      it { should == 'Accepted' }
    end

    context 'with a rejected snapshot' do
      let(:snapshot) { build(:snapshot, :rejected) }
      it { should == 'Rejected' }
    end

    context 'with a pending snapshot' do
      let(:snapshot) { build(:snapshot, :pending) }
      it { should == 'Pending' }
    end

    context 'with a snapshot under review' do
      let(:snapshot) { build(:snapshot) }
      it { should == 'Under review' }
    end
  end
end
