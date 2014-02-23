require 'spec_helper'

describe ViewportsController do
  render_views

  let(:viewport) { create :viewport }

  describe '#edit' do
    subject do
      get :edit, id: viewport.to_param
      response
    end

    it { should be_success }
    it { should render_template('viewports/edit') }
  end

  describe '#update' do
    let(:width)      { '600' }
    let(:user_agent) { nil }

    subject do
      post :update, id: viewport.to_param,
                    viewport: { user_agent: user_agent, width: width }
      response
    end

    it { should be_redirect }

    it 'saves the new width' do
      expect { subject }.to change { viewport.reload.width }.to width.to_i
    end

    context 'with a missing width' do
      let(:width) { '' }

      it { should render_template('viewports/edit') }
    end

    context 'with a user agent' do
      let(:user_agent) { 'Foo' }

      it 'saves the user agent' do
        expect { subject }.to change { viewport.reload.user_agent }.to user_agent
      end
    end
  end
end
