require 'spec_helper'
require 'oily_png'

describe SnapshotComparer do
  describe '#compare!' do
    let(:snapshot1)         { build(:snapshot) }
    let(:snapshot2)         { build(:snapshot) }
    let(:snapshot_comparer) { SnapshotComparer.new(snapshot1, snapshot2) }
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
        snapshot_comparer.expects(:to_chunky_png).with(snapshot1)
          .returns(ChunkyPNG::Image.new(10, 10, ChunkyPNG::Color::WHITE))
        snapshot_comparer.expects(:to_chunky_png).with(snapshot2)
          .returns(ChunkyPNG::Image.new(20, 10, ChunkyPNG::Color::BLACK))
      end

      it 'should report a difference' do
        subject[:diff_in_percent].should == 100
      end
    end
  end
end
