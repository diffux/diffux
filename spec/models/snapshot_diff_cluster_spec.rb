require 'spec_helper'

describe SnapshotDiffCluster do
  let(:start)  { 10 }
  let(:finish) { start + 5 }
  let(:snapshot_diff_cluster) do
    create(:snapshot_diff_cluster, start: start, finish: finish)
  end

  describe '#relative_start' do
    subject { snapshot_diff_cluster.relative_start(image_height) }

    context 'when start is 0' do
      let(:start) { 0 }

      context 'when image_height is 100' do
        let(:image_height) { 100 }
        it { should == 0.0 }
        it { should be_a(Float) }
      end

      context 'when image_height is 0' do
        let(:image_height) { 0 }
        it { should == 0.0 }
        it { should be_a(Float) }
      end
    end

    context 'when start is half the image height' do
      let(:start)        { 500 }
      let(:image_height) { 1_000 }
      it { should == 50.0 }
      it { should be_a(Float) }
    end

    context 'when start is at the image height' do
      let(:start)        { 4 }
      let(:image_height) { 4 }
      it { should == 100.0 }
      it { should be_a(Float) }
    end
  end

  describe '#relative_height' do
    subject { snapshot_diff_cluster.relative_height(image_height) }

    context 'when cluster spans half of the image' do
      let(:start)        { 0 }
      let(:finish)       { 499 }
      let(:image_height) { 1_000 }
      it { should == 50.0 }
      it { should be_a(Float) }
    end

    context 'when cluster spans entire image' do
      let(:start)        { 0 }
      let(:finish)       { 3 }
      let(:image_height) { 4 }
      it { should == 100.0 }
      it { should be_a(Float) }
    end

    context 'when image has no height' do
      let(:image_height) { 0 }
      it { should == 0.0 }
      it { should be_a(Float) }
    end
  end
end
