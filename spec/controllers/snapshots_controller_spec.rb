require 'spec_helper'

describe SnapshotsController do
  render_views

  describe '#show' do
    let(:snapshot) { create(:snapshot) }
    subject        { get :show, id: snapshot.to_param }

    it         { should be_success }
    its(:body) { should include('Snapshot image') }
    its(:body) { should include('Under review') }

    context 'with a snapshot in pending state' do
      let(:snapshot) { create(:snapshot, :pending) }

      it         { should be_success }
      its(:body) { should_not include('Snapshot image') }
      its(:body) { should include('Pending') }
      its(:body) { should_not include('Under review') }
    end
  end

  describe '#create' do
    let(:url)      { create :url }
    let(:baseline) { create :snapshot }

    before do
      prc = Proc.new do |snapshot, file|
        # Since we're not actually taking snapshots, we need to fake the image.
        snapshot.image = File.open("#{Rails.root}/spec/sample_snapshot.png")
      end
      Snapshotter.any_instance.stubs(:save_file_to_snapshot).with(&prc)
      SnapshotComparer.any_instance.stubs(:compare!).returns(
        diff_image:      ChunkyPNG::Image.new(10, 10, ChunkyPNG::Color::WHITE),
        diff_in_percent: 0.001
      )
      Url.any_instance.stubs(:baseline).returns(baseline)
    end

    subject do
      post :create, url: url.to_param
      response
    end

    it 'adds a snapshot' do
      expect { subject }.to change { Snapshot.count }.by(1)
    end

    it 'saves the diff' do
      subject
      snapshot = Snapshot.unscoped.last
      snapshot.diff_from_previous.should == 0.001
      snapshot.diffed_with_snapshot.should == baseline
    end

    it 'captures the snapshot title' do
      subject
      snapshot = Snapshot.unscoped.last
      snapshot.title.should_not be_nil
    end

    context 'with a baseline' do
      before do
        create(:snapshot, :accepted, url: url)
      end

      it 'adds a snapshot' do
        expect { subject } .to change { Snapshot.count }.by(1)
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
