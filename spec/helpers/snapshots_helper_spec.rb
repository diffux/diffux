require 'spec_helper'

describe SnapshotsHelper do
  describe '#glyphicon_for' do
    subject { glyphicon_for(snapshot) }

    context 'with an accepted snapshot' do
      let(:snapshot) { build(:snapshot, :accepted) }
      it { should == 'glyphicon-ok-sign' }
    end

    context 'with a rejected snapshot' do
      let(:snapshot) { build(:snapshot, :rejected) }
      it { should == 'glyphicon-remove-sign' }
    end

    context 'with a pending snapshot' do
      let(:snapshot) { build(:snapshot, :pending) }
      it { should be_nil }
    end

    context 'with a snapshot under review' do
      let(:snapshot) { build(:snapshot) }
      it { should == 'glyphicon-question-sign' }
    end
  end
end
