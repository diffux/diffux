require 'spec_helper'

describe Snapshotter do
  let(:url)      { create :url }
  let(:viewport) { create :viewport }
  subject        { Snapshotter.new(url, viewport) }

  describe '#take_snapshot!' do
    let(:external_image_id) { rand(1_000) }

    before do
      Phantomjs.stubs(:run).yields(encoded_output)
      FileUtil.stubs(:upload_to_cloudinary).returns(external_image_id)
    end

    context 'when snapshot script outputs JSON' do
      let(:decoded_output) { { something: rand(1_000).to_s } }
      let(:encoded_output) { ActiveSupport::JSON.encode(decoded_output) }

      it 'returns the decoded JSON' do
        response = subject.take_snapshot!
        (decoded_output.to_a - response.to_a).should == []
      end

      it 'uploads the file to Cloudinary' do
        FileUtil.expects(:upload_to_cloudinary)
        subject.take_snapshot!
      end

      it 'includes the external image ID' do
        subject.take_snapshot![:external_image_id].should == external_image_id
      end
    end

    context 'when snapshot script outputs non-JSON' do
      let(:encoded_output) { 'This is not JSON' }
      it 'raises an error with the script output' do
        expect { subject.take_snapshot! }.to raise_error(encoded_output)
      end
    end
  end
end
