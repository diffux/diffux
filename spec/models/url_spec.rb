require 'spec_helper'
describe Url do
  let(:name) { 'a simple name' }
  let(:url)  { create(:url, name: name) }

  describe '#to_param' do
    subject { url.to_param }
    it      { should == "#{url.id}-a-simple-name" }
  end

  describe '#baseline' do
    subject { url.baseline }
    it      { should be_nil }

    context 'with a rejected snapshot' do
      let!(:rejected_snapshot) { create(:snapshot, url: url, rejected_at: Time.now) }
      it { should be_nil }

      context 'with two accepted snapshots' do
        let!(:old_snapshot) { create(:snapshot, url: url, accepted_at: 1.day.ago) }
        let!(:new_snapshot) { create(:snapshot, url: url, accepted_at: 1.hour.ago) }

        it { old_snapshot.url.should == url  }
        it { old_snapshot.accepted_at == url  }
        it { should == new_snapshot }
      end
    end
  end
end
