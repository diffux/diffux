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

  describe '#menu_item' do
    subject { helper.menu_item 'Text', path }
    before  { helper.request.stubs(:fullpath).returns(fullpath) }

    context 'when you are currently on a project page' do
      let(:fullpath) { project_path(build_stubbed :project) }

      context 'and you are rendering the projects link' do
        let(:path) { projects_path }

        it 'should render an active item' do
          subject.should =~ /class="active"/
        end
      end

      context 'and you are rendering the "About" link' do
        let(:path) { static_pages_about_path }

        it 'should not render an active item' do
          subject.should_not =~ /class="active"/
        end
      end
    end
  end
end
