require 'spec_helper'
describe Sweep do
  describe '#refresh!' do
    let(:sweep) { create :sweep }
    subject     { sweep.refresh! }

    describe '#update_counters!' do
      let!(:snapshot) { create :snapshot, state, sweep: sweep }

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

    describe '#send_email_if_needed' do
      context 'when there are no snapshots' do
        it 'sends no email' do
          expect { subject }
            .to_not change { ActionMailer::Base.deliveries.count }
        end
      end

      context 'with a snapshot in pending state' do
        before do
          create(:snapshot, :pending, sweep: sweep)
        end

        it 'sends no email' do
          expect { subject }
            .to_not change { ActionMailer::Base.deliveries.count }
        end
      end

      context 'with all snapshots in under_review state' do
        before do
          2.times { create(:snapshot, sweep: sweep) }
        end

        it 'sends an email' do
          expect { subject }
            .to change { ActionMailer::Base.deliveries.count }.by(1)
        end

        it 'sends an email to the right address' do
          subject
          ActionMailer::Base.deliveries.last.to.should == [sweep.email]
        end
      end

      context 'with a mix of snapshot states, one in pending' do
        before do
          create(:snapshot, :pending,  sweep: sweep)
          create(:snapshot, :accepted, sweep: sweep)
          create(:snapshot, :rejected, sweep: sweep)
        end

        it 'sends no email' do
          expect { subject }
            .to_not change { ActionMailer::Base.deliveries.count }
        end
      end

      context 'with a mix of snapshot states, none in pending' do
        before do
          create(:snapshot, :accepted, sweep: sweep)
          create(:snapshot, :rejected, sweep: sweep)
          create(:snapshot, sweep: sweep)
        end

        it 'sends an email' do
          expect { subject }
            .to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end

      context 'when email has already been sent' do
        before do
          create(:snapshot, sweep: sweep)
          sweep.emailed_at = Time.now - 1.day
          sweep.save!
        end

        it 'does not send another email' do
          expect { subject }
            .to_not change { ActionMailer::Base.deliveries.count }
        end
      end

      context 'when email address is missing' do
        let(:sweep) { create(:sweep, email: email) }
        before      { create(:snapshot, sweep: sweep) }

        context 'and is nil' do
          let(:email) { nil }

          it 'does not send an email' do
            expect { subject }
              .to_not change { ActionMailer::Base.deliveries.count }
          end
        end

        context 'and is empty' do
          let(:email) { '' }

          it 'does not send an email' do
            expect { subject }
              .to_not change { ActionMailer::Base.deliveries.count }
          end
        end
      end
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

    context 'with an invalid email address' do
      subject { build(:sweep, email: 'foo') }

      it { should have(1).error_on(:email) }
    end

    context 'with no email address' do
      subject { create(:sweep, email: nil) }

      it 'does not raise error' do
        expect { subject }.to_not raise_error
      end
    end
  end
end
