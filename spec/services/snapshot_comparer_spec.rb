require 'spec_helper'
require 'oily_png'

describe SnapshotComparer do
  describe '#compare!' do
    let(:snapshot_after)    { build(:snapshot) }
    let(:snapshot_before)   { build(:snapshot) }
    let(:snapshot_comparer) do
      SnapshotComparer.new(snapshot_after, snapshot_before)
    end
    subject { snapshot_comparer.compare! }

    context 'with equal snapshots' do
      before do
        snapshot_comparer.stubs(:to_chunky_png)
          .returns(ChunkyPNG::Image.new(10, 10, ChunkyPNG::Color::WHITE))
      end

      it 'should report no difference' do
        subject[:diff_in_percent].should == 0
      end
    end

    context 'with different snapshots' do
      before do
        snapshot_comparer.expects(:to_chunky_png).with(snapshot_after)
          .returns(ChunkyPNG::Image.new(10, 10, ChunkyPNG::Color::WHITE))
        snapshot_comparer.expects(:to_chunky_png).with(snapshot_before)
          .returns(ChunkyPNG::Image.new(10, 10, ChunkyPNG::Color::BLACK))
      end

      it 'should report a difference' do
        subject[:diff_in_percent].should == 100
      end
    end
  end
end
