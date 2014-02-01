require 'spec_helper'

describe UrlsController do
  render_views

  describe '#index' do
    subject do
      get :index
      response
    end

    context 'with no added URLs' do
      it { should be_success }
    end

    context 'with one URL' do
      let(:url) { create(:url) }

      it { should be_success }
      its(:body) { should include url.address }
    end
  end

  describe '#show' do
    let(:params) { { id: url.to_param } }
    subject do
      get :show, params
      response
    end

    context 'with an existing URL' do
      let(:url) { create(:url) }
      it { should be_success }
      its(:body) { should include url.address }

      context 'with snapshots' do
        before { 2.times { create(:snapshot, url: url) } }
        it     { should be_success }
      end
    end

    context 'with a non-existing URL' do
      let(:params) { { id: '-1' } }

      it 'raises an error' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end


  describe 'manipulation' do
    let(:address) { "https://www.#{Random.rand(1_000)}.causes.com" }
    let(:width)   { '320' }
    let(:params) do {
      address: address,
      viewport_width: width,
    }
    end

    describe '#create' do
      context 'with valid params' do
        it 'adds a Url' do
          expect { post :create, url: params }.to change { Url.count }.by(1)
        end
      end
    end

    describe '#update' do
      let(:url) { create(:url) }
      subject do
        post :update, url: params, id: url.to_param
        url.reload
      end

      context 'with valid params' do
        its(:address)          { should == address }
        its(:viewport_width)   { should == 320 }
      end

      context 'with invalid address' do
        let(:address) { 'not a url' }

        it 'does not update the url' do
          subject.address.should_not == address
        end
      end
    end
  end

  describe '#edit' do
    let(:url) { create(:url) }
    subject do
      get :edit, { id: url.to_param }
      response
    end

    it { should be_success }
    it { should render_template('urls/edit') }
  end

  describe '#destroy' do
    let!(:url) { create(:url) }

    it 'removes the url' do
      expect { delete :destroy, id: url.to_param }
        .to change { Url.all.count }.by(-1)
    end
  end
end
