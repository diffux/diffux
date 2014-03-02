require 'spec_helper'

describe Snapshot do
  let(:snapshot) { create(:snapshot) }
  subject        { snapshot }

  describe 'rejecting/accepting' do
    its(:accepted?) { should == false }
    its(:rejected?) { should == false }

    describe '#accept!' do
      before { snapshot.accept! }

      its(:accepted?) { should == true }
      its(:rejected?) { should == false }
    end

    describe '#reject!' do
      before { snapshot.reject! }

      its(:accepted?) { should == false }
      its(:rejected?) { should == true }
    end
  end

  describe '#pending?' do
    let(:snapshot) { create :snapshot, :pending }
    subject        { snapshot.pending? }

    it { should be_true }

    context 'when waiting for a diff' do
      let(:snapshot) { create :snapshot }

      context 'when there is a baseline' do
        before do
          snapshot.url.stubs(:baseline)
            .returns(build(:snapshot, created_at: created_at))
        end

        context 'and the baseline is older than the snapshot' do
          let(:created_at) { 5.days.ago }
          it               { should be_true }
        end

        context 'and the baseline is newer than the snapshot' do
          let(:created_at) { 5.days.from_now }
          it               { should be_false }
        end
      end

      context 'when the baseline is equal to the snapshot' do
        before { snapshot.url.stubs(:baseline).returns(snapshot) }
        it     { should be_false }
      end

      context 'when there is no baseline' do
        before { snapshot.url.stubs(:baseline).returns(nil) }
        it     { should be_false }
      end
    end
  end

  describe '#auto_accept' do
    context 'with a diff' do
      before do
        snapshot.create_snapshot_diff!(diff_in_percent: diff)
      end

      context 'with a percentage above zero' do
        let(:diff) { 3 }

        it 'does not auto-accept' do
          expect { subject.save! }.to_not change { snapshot.accepted? }
        end
      end

      context 'with a percentage of zero' do
        let(:diff) { 0 }

        it 'auto-accepts the snapshot' do
          expect { subject.save! }.to change { snapshot.accepted? }.to(true)
        end

        context 'when the diff image is the same as the snapshot' do
          before { snapshot.snapshot_diff.before_snapshot = snapshot }

          it 'does not auto-accept' do
            expect { subject.save! }.to_not change { snapshot.accepted? }
          end
        end
      end
    end

    context 'with missing diff' do
      it 'does not auto-accept' do
        expect { subject.save! }.to_not change { snapshot.accepted? }
      end
    end
  end

  describe '#diff?' do
    subject { snapshot.diff? }

    context 'without a diff' do
      it { should be_false }
    end

    context 'with a diff' do
      before  do
        snapshot.create_snapshot_diff!(
          before_snapshot_id: diffed_with_snapshot.id,
          diff_in_percent: 1.0)
      end

      context 'of a different snapshot' do
        let(:diffed_with_snapshot) { create :snapshot }
        it { should be_true }
      end

      context 'of the same snapshot' do
        let(:diffed_with_snapshot) { snapshot }
        it { should be_false }
      end
    end
  end

  describe '#refresh_sweep', :uses_after_commit do
    subject { snapshot.save! }

    context 'on creation' do
      let(:snapshot) { build :snapshot, :with_sweep }

      it 'calls #refresh! for the sweep' do
        snapshot.sweep.expects(:refresh!).once
        subject
      end
    end

    context 'on update' do
      let!(:snapshot) { create :snapshot, :with_sweep }

      it 'calls #refresh! for the sweep' do
        snapshot.sweep.expects(:refresh!)
        subject
      end
    end

    context 'with a snapshot not attached to a sweep' do
      let(:snapshot) { build :snapshot }

      it 'does not fail' do
        expect { subject }.to_not raise_error
      end
    end
  end
end
