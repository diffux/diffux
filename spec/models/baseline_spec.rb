require 'spec_helper'

describe Baseline do
  describe '#create' do
    let(:url) do
      Url.create(address: 'https://www.causes.com/',
                 name: 'Causes start page',
                 viewport_width: 320)
    end
    let(:snapshot) do
      Snapshot.create(url_id: url.id)
    end

    subject { Baseline.create(url_id: url.id, snapshot_id: snapshot.id) }
    it      { should be_valid }

    context 'with another Baseline created for the same URL' do
      before do
        Baseline.create(url_id: url.id, snapshot_id: snapshot.id)
      end

      it { should_not be_valid }
      it { should have(1).error_on(:url_id) }
      it { should have(1).error_on(:snapshot_id) }
    end
  end
end
