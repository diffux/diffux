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

    context 'with identical snapshots' do
      before do
        snapshot_comparer.stubs(:to_chunky_png)
          .returns(ChunkyPNG::Image.new(2, 2, ChunkyPNG::Color::WHITE))
      end

      it 'should report no difference' do
        subject[:diff_in_percent].should == 0.0
      end

      it 'should report no diff image' do
        subject[:diff_image].should be_nil
      end

      it 'should report no cluster differences' do
        subject[:diff_clusters].should be_empty
      end
    end

    context 'with entirely different snapshots' do
      before do
        snapshot_comparer.stubs(:to_chunky_png).with(snapshot_after)
          .returns(ChunkyPNG::Image.new(2, 2, ChunkyPNG::Color::WHITE))
        snapshot_comparer.stubs(:to_chunky_png).with(snapshot_before)
          .returns(ChunkyPNG::Image.new(2, 2, ChunkyPNG::Color::BLACK))
      end

      it 'should report a 100% difference' do
        subject[:diff_in_percent].should == 100.0
      end

      it 'should report a diff image' do
        subject[:diff_image].should_not be_nil
      end

      it 'should report one cluster difference' do
        subject[:diff_clusters].count.should == 1
      end
    end

    context 'when the after snapshot is half as tall as the before snapshot' do
      before do
        snapshot_comparer.stubs(:to_chunky_png).with(snapshot_after)
          .returns(ChunkyPNG::Image.new(2, 2, ChunkyPNG::Color::BLACK))
        snapshot_comparer.stubs(:to_chunky_png).with(snapshot_before)
          .returns(ChunkyPNG::Image.new(2, 1, ChunkyPNG::Color::BLACK))
      end

      it 'should report a 50% difference' do
        subject[:diff_in_percent].should == 50.0
      end

      it 'should report one cluster difference' do
        subject[:diff_clusters].count.should == 1
      end
    end

    context 'when the after snapshot is twice as tall as the before snapshot' do
      before do
        snapshot_comparer.stubs(:to_chunky_png).with(snapshot_after)
          .returns(ChunkyPNG::Image.new(2, 2, ChunkyPNG::Color::BLACK))
        snapshot_comparer.stubs(:to_chunky_png).with(snapshot_before)
          .returns(ChunkyPNG::Image.new(2, 4, ChunkyPNG::Color::BLACK))
      end

      it 'should report a 50% difference' do
        subject[:diff_in_percent].should == 50.0
      end

      it 'returns an image of the correct height' do
        subject[:diff_image].height.should == 4
      end

      it 'should report one cluster difference' do
        subject[:diff_clusters].count.should == 1
      end
    end

    context 'when the after snapshot half as wide as the before snapshot' do
      before do
        snapshot_comparer.stubs(:to_chunky_png).with(snapshot_after)
          .returns(ChunkyPNG::Image.new(2, 2, ChunkyPNG::Color::BLACK))
        snapshot_comparer.stubs(:to_chunky_png).with(snapshot_before)
          .returns(ChunkyPNG::Image.new(1, 2, ChunkyPNG::Color::BLACK))
      end

      it 'should report a 100% difference' do
        subject[:diff_in_percent].should == 100.0
      end
    end

    context 'when the before snapshot is twice as wide as the before snapshot' do
      before do
        snapshot_comparer.stubs(:to_chunky_png).with(snapshot_after)
          .returns(ChunkyPNG::Image.new(2, 2, ChunkyPNG::Color::BLACK))
        snapshot_comparer.stubs(:to_chunky_png).with(snapshot_before)
          .returns(ChunkyPNG::Image.new(4, 2, ChunkyPNG::Color::BLACK))
      end

      it 'should report a 100% difference' do
        subject[:diff_in_percent].should == 100.0
      end
    end

    context 'when the after snapshot is twice as wide as the before snapshot' do
      before do
        snapshot_comparer.stubs(:to_chunky_png).with(snapshot_after)
          .returns(ChunkyPNG::Image.new(4, 2, ChunkyPNG::Color::BLACK))
        snapshot_comparer.stubs(:to_chunky_png).with(snapshot_before)
          .returns(ChunkyPNG::Image.new(2, 2, ChunkyPNG::Color::BLACK))
      end

      it 'should report a 100% difference' do
        subject[:diff_in_percent].should == 100.0
      end
    end
  end
end
