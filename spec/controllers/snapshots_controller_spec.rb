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

  describe '#accept' do
    let!(:snapshot) { create(:snapshot) }

    it 'accepts the snapshot' do
      expect { post :accept, id: snapshot.to_param }
        .to change { snapshot.reload.accepted? }.to(true)
    end
  end

  describe '#reject' do
    let!(:snapshot) { create(:snapshot) }

    it 'rejects the snapshot' do
      expect { post :reject, id: snapshot.to_param }
        .to change { snapshot.reload.rejected? }.to(true)
    end
  end
end
