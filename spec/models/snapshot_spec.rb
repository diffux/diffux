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

  describe '#auto_accept' do
    before { snapshot.diff_from_previous = diff }

    context 'with a diff' do
      let(:diff) { 3 }

      it 'does not auto-accept' do
        expect { subject.save! }.to_not change { snapshot.accepted? }
      end
    end

    context 'with no diff' do
      let(:diff) { 0 }

      it 'auto-accepts the snapshot' do
        expect { subject.save! }.to change { snapshot.accepted? }.to(true)
      end
    end

    context 'with a nil diff' do
      let(:diff) { nil }

      it 'auto-accepts the snapshot' do
        expect { subject.save! }.to_not change { snapshot.accepted? }
      end
    end
  end
end
