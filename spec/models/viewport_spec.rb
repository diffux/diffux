require 'spec_helper'
describe Viewport do
  describe '#height' do
    subject { create :viewport, width: width }

    context 'with a narrow width' do
      let(:width) { 320 }

      it 'is a portrait aspect ratio' do
        subject.height.should be > subject.width
      end
    end

    context 'with a wide width' do
      let(:width) { 1024 }

      it 'is a landscape aspect ratio' do
        subject.height.should be < subject.width
      end
    end
  end
end
