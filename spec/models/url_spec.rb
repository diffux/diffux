require 'spec_helper'
describe Url do
  let(:url)      { create(:url) }
  let(:viewport) { create(:viewport) }

  describe 'title' do
    let(:url) { create(:url, address:"http://google.com") }
    subject   { url.title }
    it        { should == "google.com" }

    context 'with a nonaccepted snapshot' do
      before do
        create(:snapshot, url: url)
      end

      it { should == "google.com" }
    end

    context 'with a accepted snapshot' do
      let!(:accepted_snapshot) do
        create(:snapshot, :accepted, url: url)
      end

      it { should == accepted_snapshot.title }
    end

    context 'with two accepted snapshots' do
      let!(:accepted_snapshot1) do
        create(:snapshot, :accepted, url: url, created_at: Time.now - 5.minutes)
      end
      let!(:accepted_snapshot2) do
        create(:snapshot, :accepted, url: url, created_at: Time.now)
      end

      it { should == accepted_snapshot2.title }
    end

  end

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

  describe '#last_snapshots_by_viewport' do
    let(:viewport) { url.project.viewports.first }
    subject        { url.last_snapshots_by_viewport }

    it { should be_a Hash }

    context 'with no snapshots' do
      it 'returns a viewport with no snapshots' do
        subject[viewport].should be_empty
      end
    end

    context 'with three snapshots' do
      before do
        3.times { create(:snapshot, url: url, viewport: viewport) }
      end

      it 'the viewport in the result has two snapshots' do
        subject[viewport].count.should == 2
      end
    end

    context 'with more than one viewport' do
      before { create(:viewport, project: url.project) }

      it 'returns all viewports' do
        subject.keys.count.should == 2
      end
    end
  end
end
