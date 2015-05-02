require 'spec_helper'

describe UrlsController, type: :controller do
  render_views

  let!(:url) { create(:url) }

  describe '#show' do
    subject do
      get :show, id: url.to_param
      response
    end

    it { should be_success }
    it { should render_template('urls/show') }
    its(:body) { should include url.title }

    context 'with snapshots' do
      let(:snapshot) { create :snapshot, url: url }

      its(:body) { should include snapshot.viewport.to_s }
      its(:body) { should include snapshot_path(snapshot) }
    end
  end

  describe '#destroy' do
    let(:referer) { "/path#{Random.rand(100_000).to_s}" }

    before do
      request.env['HTTP_REFERER'] = referer
    end

    subject do
      delete :destroy, id: url.to_param
      response
    end

    it { should redirect_to referer }

    it 'removes the url' do
      expect { subject }.to change { Url.all.count }.by(-1)
    end
  end
end
