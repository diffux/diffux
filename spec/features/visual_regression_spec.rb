require 'spec_helper'

describe 'Visual diffs', js: true, without_transactional_fixtures: true do
  before do
    Phantomjs.unstub(:run)
  end

  context 'Project#index' do
    let(:path)   { projects_path }

    it 'has a nice button design' do
      expect(path).to look_like_before(crop_selector: '.btn')
    end

    [320, 1000].each do |width|
      context 'with no added project' do
        it 'has no visual regressions' do
          expect(path).to look_like_before(at_width: width)
        end
      end

      context 'with added projects' do
        before { create :project, name: 'Foo' }

        it 'has no visual regressions' do
          expect(path).to look_like_before(at_width: width)
        end
      end
    end
  end
end
