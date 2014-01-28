require 'spec_helper'

describe StaticPagesController do
  render_views

  describe '#about' do
    subject do
      get :about
      response
    end

    it { should be_success }
    its(:body) { should include('About') }
    it { should render_template('static_pages/about') }
  end
end
