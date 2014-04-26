require 'spec_helper'
require 'oily_png'

describe SnapshotComparer do

  def image(width: 2, height: 2, color: ChunkyPNG::Color::WHITE)
    ChunkyPNG::Image.new(width, height, color)
  end

  describe '#compare!' do
    let(:png_before) { image }
    let(:png_after)  { image }
    let(:snapshot_comparer) do
      SnapshotComparer.new(png_before, png_after)
    end
    subject { snapshot_comparer.compare! }

    context 'with identical snapshots' do
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
      let(:png_after) { image(color: ChunkyPNG::Color::BLACK) }

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
      let(:png_after) { image(height: 1) }

      it 'should report a 50% difference' do
        subject[:diff_in_percent].should == 50.0
      end

      it 'should report one cluster difference' do
        subject[:diff_clusters].count.should == 1
      end
    end

    context 'when the after snapshot is twice as tall as the before snapshot' do
      let(:png_after) { image(height: 4) }

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
      let(:png_after) { image(width: 1) }

      it 'should report a 100% difference' do
        subject[:diff_in_percent].should == 100.0
      end
    end

    context 'when the before snapshot is twice as wide as the after snapshot' do
      let(:png_before) { image(width: 4) }

      it 'should report a 100% difference' do
        subject[:diff_in_percent].should == 100.0
      end
    end

    context 'when the after snapshot is twice as wide as the before snapshot' do
      let(:png_after) { image(width: 4) }

      it 'should report a 100% difference' do
        subject[:diff_in_percent].should == 100.0
      end
    end
  end
end
