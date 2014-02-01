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
    its(:body) { should include(snapshot.url.address) }
    it { should render_template('snapshots/show') }
  end

  describe '#create' do
    let(:external_image_id) { rand(100) }
    let(:title)             { rand(100_000).to_s }
    let(:url)               { create(:url) }

    before do
      Snapshotter.any_instance.stubs(:take_snapshot!).returns(
        title:              title,
        external_image_id:  external_image_id
      )

      SnapshotComparer.any_instance.stubs(:compare!).returns(
        external_image_id: external_image_id,
        diff_in_percent:   0.001
      )
    end

    it 'adds a snapshot' do
      expect { post :create, url: url.to_param }
               .to change { Snapshot.count }.by(1)
    end

    it 'captures the snapshot title' do
      post :create, url: url.to_param

      snapshot = Snapshot.unscoped.last
      snapshot.title.should == title
    end

    context 'with a baseline' do
      before do
        create(:snapshot, :accepted, url: url)
      end

      it 'adds a snapshot' do
        expect { post :create, url: url.to_param }
                 .to change { Snapshot.count }.by(1)
      end
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
