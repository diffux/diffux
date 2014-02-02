require 'spec_helper'

describe UrlsController do
  render_views

  describe '#destroy' do
    let!(:url) { create(:url) }
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
