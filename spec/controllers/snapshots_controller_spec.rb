require 'spec_helper'

describe SnapshotsController do
  render_views

  describe '#show' do
    let(:snapshot) { create(:snapshot) }
    subject        { get :show, id: snapshot.to_param }

    it         { should be_success }
    its(:body) { should have_css('.snapshot-accept-button') }
    its(:body) { should have_css('.snapshot-reject-button') }
    its(:body) { should_not have_link('View debug log') }

    context 'with a snapshot in pending state' do
      let(:snapshot) { create(:snapshot, :pending) }

      it         { should be_success }
      its(:body) { should include('Pending') }
      its(:body) { should_not have_css('.snapshot-accept-button') }
      its(:body) { should_not have_css('.snapshot-reject-button') }
    end

    context 'with a snapshot in accepted state' do
      let(:snapshot) { create(:snapshot, :accepted) }

      it         { should be_success }
      its(:body) { should have_css('.snapshot-accept-button') }
      its(:body) { should have_css('.snapshot-reject-button') }
    end

    context 'with a snapshot in rejected state' do
      let(:snapshot) { create(:snapshot, :rejected) }

      it         { should be_success }
      its(:body) { should have_css('.snapshot-accept-button') }
      its(:body) { should have_css('.snapshot-reject-button') }
    end

    context 'with a log' do
      before { snapshot.update_attributes log: 'a log' }

      its(:body) { should have_link 'View debug log' }
    end
  end

  describe '#create' do
    let(:url)           { create :url }
    let(:baseline)      { create :snapshot }
    let(:diff_clusters) {  [{ start: 0, finish: 5 }] }
    before do
      prc = proc do |snapshot, file|
        # Since we're not actually taking snapshots, we need to fake the image.
        snapshot.image = File.open("#{Rails.root}/spec/sample_snapshot.png")
      end
      SnapshotterWorker.any_instance.stubs(:save_file_to_snapshot).with(&prc)
      Diffux::SnapshotComparer.any_instance.stubs(:compare!).returns(
        diff_image:      ChunkyPNG::Image.new(10, 10, ChunkyPNG::Color::WHITE),
        diff_in_percent: 0.001,
        diff_clusters:   diff_clusters,
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

    it 'saves the diff', :without_transactional_fixtures do
      subject
      diff = Snapshot.unscoped.last.snapshot_diff
      diff.diff_in_percent.should == 0.001
      diff.before_snapshot.should == baseline
    end

    it 'saves the diff cluster', :without_transactional_fixtures do
      subject
      diff = Snapshot.unscoped.last.snapshot_diff
      diff.snapshot_diff_clusters.count.should == 1
      diff.snapshot_diff_clusters.first.start.should ==
        diff_clusters.first[:start]
    end

    it 'captures the snapshot title', :without_transactional_fixtures do
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

    subject do
      post :accept, id: snapshot.to_param
      response
    end

    it 'accepts the snapshot' do
      expect { subject }.to change { snapshot.reload.accepted? }.to(true)
    end

    it { should redirect_to(snapshot_url(snapshot)) }

    context 'with an XHR request' do
      subject do
        xhr :post, :accept, id: snapshot.to_param
        response
      end

      it { should_not redirect_to(snapshot_url(snapshot)) }
      it { should render_template('snapshots/_header_and_buttons') }
    end
  end

  describe '#reject' do
    let!(:snapshot) { create(:snapshot) }

    subject do
      post :reject, id: snapshot.to_param
      response
    end

    it 'rejects the snapshot' do
      expect { subject }.to change { snapshot.reload.rejected? }.to(true)
    end

    it { should redirect_to(snapshot_url(snapshot)) }

    context 'with an XHR request' do
      subject do
        xhr :post, :reject, id: snapshot.to_param
        response
      end

      it { should_not redirect_to(snapshot_url(snapshot)) }
      it { should render_template('snapshots/_header_and_buttons') }
    end
  end

  describe '#view_log' do
    let(:log)      { 'a log' }
    let(:snapshot) { create :snapshot, log: log }
    subject        { get :view_log, id: snapshot.to_param }
    its(:body)     { should have_content log }

    context 'with no log saved for the snapshot' do
      let(:log)  { nil }
      its(:body) { should have_css '.alert.alert-warning' }
    end
  end

  describe '#take_snapshot', :without_transactional_fixtures  do
    let!(:snapshot) { create(:snapshot, :with_baseline, :with_diff) }

    before { SnapshotterWorker.stubs(:perform_async) }

    subject do
      post :take_snapshot, id: snapshot.to_param
      response
    end

    it 'sets the snapshot in pending state' do
      expect { subject }.to change { snapshot.reload.pending? }.to(true)
    end

    it 'triggers a snapshotter worker' do
      SnapshotterWorker.expects(:perform_async).once
      subject
    end

    it 'does not trigger a comparer worker' do
      SnapshotComparerWorker.expects(:perform_async).never
      subject
    end

    it { should redirect_to(snapshot_url(snapshot)) }

    context 'with an old diff' do
      let!(:snapshot) { create(:snapshot, :with_diff) }

      it 'deletes the snapshot diff' do
        expect { subject }.to change { snapshot.reload.snapshot_diff }.to(nil)
      end

      it 'keeps the compared_with snapshot' do
        expect { subject }.to_not change { snapshot.compared_with }
      end
    end
  end

  describe '#compare_snapshot' do
    let!(:snapshot) { create(:snapshot, :accepted, :with_baseline) }

    before { SnapshotComparerWorker.stubs(:perform_async) }

    subject do
      post :compare_snapshot, id: snapshot.to_param
      response
    end

    it 'sets the snapshot in pending state', :without_transactional_fixtures do
      expect { subject }.to change { snapshot.reload.pending? }.to(true)
    end

    it 'triggers a worker', :without_transactional_fixtures do
      SnapshotComparerWorker.expects(:perform_async).once
      subject
    end

    it 'keeps the compared_with snapshot' do
      expect { subject }.to_not change { snapshot.compared_with }
    end

    it { should redirect_to(snapshot_url(snapshot)) }
  end
end
