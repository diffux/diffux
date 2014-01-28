require 'spec_helper'

describe SnapshotsController do
  render_views

  describe '#show' do
    let(:snapshot) { create(:snapshot) }
    subject do
      get :show, id: snapshot.to_param
      response
    end

    it { should be_success }
    its(:body) { should include(snapshot.url.name) }
    it { should render_template('snapshots/show') }
  end

  describe '#create' do
    let(:url) { create(:url) }

    it 'adds a snapshot' do
      expect { post :create, url: url.to_param }
               .to change { Snapshot.count }.by(1)
    end
  end

  describe '#destroy' do
    let!(:snapshot) { create(:snapshot) }

    it 'removes a snapshot' do
      expect { delete :destroy, id: snapshot.to_param }
        .to change { Snapshot.count }.by(-1)
    end
  end

  describe '#set_as_baseline' do
    let(:snapshot) { create(:snapshot) }

    it 'makes the snapshot the baseline for the url' do
      expect { post :set_as_baseline, id: snapshot.to_param }
        .to change { snapshot.reload.baseline_for_url? }.to(true)
    end
  end
end
