require 'spec_helper'
describe Url do
  let(:url)      { create(:url) }
  let(:viewport) { create(:viewport) }

  describe '#baseline' do
    subject { url.baseline(viewport) }
    it      { should be_nil }

    context 'with a rejected snapshot' do
      let!(:rejected_snapshot) do
        create(:snapshot, url: url, viewport: viewport, rejected_at: Time.now)
      end

      it { should be_nil }

      context 'with two accepted snapshots' do
        let!(:old_snapshot) do
          create :snapshot,
                 url:          url,
                 viewport:     viewport,
                 accepted_at:  1.day.ago
        end
        let!(:new_snapshot) do
          create :snapshot,
                 url:          url,
                 viewport:     viewport,
                 accepted_at:  1.hour.ago
        end

        it { old_snapshot.url.should == url  }
        it { old_snapshot.accepted_at == url  }
        it { should == new_snapshot }
      end
    end
  end
end
