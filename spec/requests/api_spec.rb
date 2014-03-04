require 'spec_helper'

describe 'API' do
  describe 'SweepsController#trigger' do
    let(:project) { create(:project, :with_viewport, :with_url) }
    let(:params) do
      {
        title: 'Deploy',
        description: 'Release Notes: noop',
      }
    end

    subject do
      post trigger_project_sweeps_path(project), params.to_json,
           'Content-Type' => 'application/json',
           'Accept'       => 'application/json'
    end

    context 'with valid params' do
      it 'adds a snapshot' do
        expect { subject }.to change { Snapshot.count }.by(1)
      end

      it 'sends back a json with a URL leading to the sweep' do
        subject
        response.body.should include project_sweep_url(project, Sweep.last)
        JSON.parse(response.body)['url']
          .should == project_sweep_url(project, Sweep.last)
      end

      it 'adds a sweep' do
        expect { subject }.to change { Sweep.count }.by(1)
      end
    end

    context 'with invalid params' do
      before { params.delete(:title) }

      it 'sends back a json with errors' do
        subject
        JSON.parse(response.body)['errors'].should_not be_nil
      end

      it 'has a 400 response code' do
        subject
        response.status.should == 400
      end
    end
  end
end
