require 'spec_helper'

describe RefreshController do
  render_views

  describe '#refresh' do
    let(:if_modified_since) { 2.minutes.ago }

    subject do
      post :create, { ifModifiedSince: if_modified_since.to_i }.merge(params)
      JSON.parse(response.body)
    end

    context 'with a snapshot' do
      let(:snapshot) { create :snapshot }
      let(:params)   { { snapshots: [snapshot.id] } }

      it 'sends back a json array' do
        subject['items'].should be_an(Array)
      end

      it 'returns one item' do
        subject['items'].size.should == 1
      end

      it 'has a rendered version of the snapshot' do
        item = subject['items'][0]
        item['html'].should_not be_nil
        item['id'].should   == snapshot.id
        item['type'].should == 'snapshot'
      end

      context 'with an id belonging to a missing snapshot' do
        # In case we have clients polling for deleted data
        let(:params) { { snapshots: [snapshot.id, 999999] } }

        it 'ignores the missing snapshot' do
          subject['items'].size.should == 1
        end
      end

      context 'when the snapshot was updated before `ifModifiedSince`' do
        before do
          snapshot.update_attributes(updated_at: if_modified_since - 10.seconds)
        end

        it 'returns no items' do
          subject['items'].should be_empty
        end
      end
    end
  end
end
