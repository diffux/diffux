require 'spec_helper'
describe SweepsHelper do
  describe '#sweep_status', :uses_after_commit do
    let(:counts) do
      {
        pending:      0,
        rejected:     0,
        accepted:     0,
        under_review: 0,
      }
    end
    let(:sweep) do
      build :sweep, count_rejected:     counts[:rejected],
                    count_pending:      counts[:pending],
                    count_accepted:     counts[:accepted],
                    count_under_review: counts[:under_review]
    end

    subject { sweep_status sweep }

    context 'when all snapshots are accepted' do
      before { counts[:accepted] = 10 }
      it     { should == 'All accepted' }
    end

    context 'with pending and accepted snapshots' do
      before do
        counts[:pending]  = 2
        counts[:accepted] = 5
      end

      it { should == '2 pending snapshots' }
    end

    context 'with two snapshots under review and a rejected snapshot' do
      before do
        counts[:under_review]  = 2
        counts[:rejected]      = 1
      end

      it { should == '2 snapshots under review' }
    end

    context 'with a mix of rejected and accepted snapshots' do
      before do
        counts[:accepted] = 3
        counts[:rejected] = 2
      end

      it { should == '3 accepted, 2 rejected' }
    end
  end
end
