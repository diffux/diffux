require 'spec_helper'
describe Url do
  describe '#to_param' do
    let(:name) { 'a simple name' }
    let(:url)  { create(:url, name: name) }
    subject    { url.to_param }

    it { should == "#{url.id}-a-simple-name" }
  end
end
