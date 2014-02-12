require 'spec_helper'
require 'sidekiq/testing'

describe SweepsController do
  render_views
  let(:project) { create(:project) }

  describe '#index' do
    subject do
      get :index, { project_id: project.to_param }
    end

    context 'with no sweeps' do
      it { should be_success }
    end

    context 'with two sweeps' do
      before do
        2.times { create(:sweep, project: project) }
      end

      it { should be_success }
    end
  end

  describe '#show' do
    let(:sweep) { create(:sweep, project: project) }
    subject do
      get :show, { project_id: project.to_param, id: sweep.to_param }
    end

    context 'with no snapshots' do
      it { should be_success }
    end

    context 'with a pending snapshot' do
      before do
        create(:snapshot, :pending, sweep: sweep)
      end

      it         { should be_success }
      its(:body) { should include 'Pending' }
    end

    context 'with an accepted snapshot' do
      before do
        create(:snapshot, :accepted, sweep: sweep)
      end

      it         { should be_success }
      its(:body) { should include 'Accepted' }
    end

    context 'with a rejected snapshot' do
      before do
        create(:snapshot, :rejected, sweep: sweep)
      end

      it         { should be_success }
      its(:body) { should include 'Rejected' }
    end

    context 'with a snapshot that needs review' do
      before do
        create(:snapshot, sweep: sweep)
      end

      it         { should be_success }
      its(:body) { should include 'Needs review' }
    end
  end

  describe '#new' do
    subject do
      get :new, { project_id: project.to_param }
    end

    it { should be_success }

    it 'has a pre-filled title' do
      subject
      response.body.should include 'Anonymous sweep'
    end
  end

  describe '#create' do
    let(:project)       { create(:project, :with_viewport, :with_url) }
    let(:title)         { Random.rand(10..100) }
    let(:description)   { Random.rand(100..1000) }

    let(:params) do
      {
        project_id: project.to_param,
        sweep: {
          title:       title,
          description: description,
        }
      }
    end
    subject do
      Sidekiq::Testing.fake! { post :create, params }
    end

    context 'with valid params' do
      it { should be_redirect }

      it 'adds a snapshot' do
        expect { subject }.to change { Snapshot.count }.by(1)
      end

      it 'adds a sweep' do
        expect { subject }.to change { Sweep.count }.by(1)
      end

      it 'associates the snapshot with the sweep' do
        subject
        Snapshot.last.sweep.should_not be_nil
      end

      context 'with a delay' do
        before do
          params[:sweep][:delay_seconds] = 60
        end

        it { should be_redirect }

        it 'does not add a snapshot' do
          expect { subject }.to_not change { Snapshot.count }
        end

        it 'adds a sweep' do
          expect { subject }.to change { Sweep.count }.by(1)
        end

        it 'sets a future start time to the sweep' do
          subject
          Sweep.last.start_time.should > Time.now
        end

        it 'triggers a worker thread in the future' do
          expect { subject }.to change { SweepWorker.jobs.size }.by(1)
        end
      end
    end

    context 'with a missing title' do
      let(:title) { nil }

      it { should be_succes }
      it { should render_template('sweeps/new') }

      it 'does not add a snapshot' do
        expect { subject }.to_not change { Snapshot.count }
      end

      it 'does not add a sweep' do
        expect { subject }.to_not change { Sweep.count }
      end
    end
  end
end
