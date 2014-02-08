require 'spec_helper'

describe ApplicationHelper do
  describe '#simplified_url' do
    subject { simplified_url(url) }

    context 'with https' do
      let(:url) { 'https://www.example.com' }
      it        { should == url }
    end

    context 'with http' do
      let(:simplified) { 'www.example.com' }
      let(:url)        { "http://#{simplified}" }
      it               { should == simplified }
    end

    context 'with trailing slash' do
      let(:simplified) { 'www.example.com' }
      let(:url)        { "http://#{simplified}/" }
      it               { should == simplified }
    end
  end
end
