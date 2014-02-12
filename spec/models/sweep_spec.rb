require 'spec_helper'
describe Sweep do
  describe '#update_counters!' do
    let(:sweep)     { create :sweep }
    let!(:snapshot) { create :snapshot, state, sweep: sweep }

    subject do
      sweep.update_counters!
      sweep
    end

    context 'with a pending snapshot' do
      let(:state) { :pending }

      its(:count_pending)      { should == 1 }
      its(:count_rejected)     { should == 0 }
      its(:count_accepted)     { should == 0 }
      its(:count_under_review) { should == 0 }
    end

    context 'with an accepted snapshot' do
      let(:state) { :accepted }

      its(:count_pending)      { should == 0 }
      its(:count_rejected)     { should == 0 }
      its(:count_accepted)     { should == 1 }
      its(:count_under_review) { should == 0 }
    end

    context 'with a rejected snapshot' do
      let(:state) { :rejected }

      its(:count_pending)      { should == 0 }
      its(:count_rejected)     { should == 1 }
      its(:count_accepted)     { should == 0 }
      its(:count_under_review) { should == 0 }
    end

    context 'with a snapshot under review' do
      let!(:snapshot) { create :snapshot, sweep: sweep }

      its(:count_pending)      { should == 0 }
      its(:count_rejected)     { should == 0 }
      its(:count_accepted)     { should == 0 }
      its(:count_under_review) { should == 1 }
    end
  end

  describe '#create' do
    subject { create(:sweep, delay_seconds: delay_seconds) }

    context 'with no delay' do
      let(:delay_seconds) { nil }
      its(:start_time)    { should be_nil }
    end

    context 'with a delay' do
      let(:delay_seconds) { 10 }
      its(:start_time)    { should > Time.now }
    end
  end
end
