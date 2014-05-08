require 'spec_helper'

describe 'Keyboard Shortcuts', js: true, without_transactional_fixtures: true do
  let(:focused_class) { 'keyboard-focused' }

  before do
    create_seed_project!('foobarbaz')
    visit root_path
  end

  it 'should open the help modal with the "?" shortcut' do
    press_key('?')
    expect(page).to have_content 'Keyboard shortcuts'
  end

  it 'should go up one level with the "u" shortcut' do
    click_on 'foobarbaz'
    # navigate to project page
    expect(page).to have_content 'Projects foobarbaz'
    expect(page).to have_css('h1', text: 'foobarbaz')
    press_key('u')
    # we should be back on the home page
    expect(page).not_to have_content 'Projects foobarbaz'
    expect(page).to have_css('h1', text: 'Projects')
  end

  describe 'opening focused selections' do
    shared_examples_for 'opening focused items' do
      context 'on a freshly loaded page' do
        it 'does nothing when no element is focused' do
          press_key(open_focused_shortcut)
          expect(page).not_to have_content focused_content_header
        end
      end

      it 'opens the focused content' do
        # depends on the movement shortcuts working
        press_key('k')
         press_key(open_focused_shortcut)
        expect(page).to have_content focused_content_header
      end
    end

    context 'when on project index page' do
      before do
        visit root_path
      end

      let(:focused_content_header) { 'Projects foobarbaz' }

      context 'when using "o" to open selection' do
        let(:open_focused_shortcut) { 'o' }

        it_behaves_like 'opening focused items'
      end

      context 'when using "enter" to open selection' do
        let(:open_focused_shortcut) { :Enter }

        it_behaves_like 'opening focused items'
      end
    end

    context 'when on project show page' do
      before do
        visit root_path
        click_on 'foobarbaz'
      end

      let(:focused_content_header) { 'Projects foobarbaz Sweeps' }

      context 'when using "o" to open selection' do
        let(:open_focused_shortcut) { 'o' }

        it_behaves_like 'opening focused items'
      end
      context 'when using "enter" to open selection' do
        let(:open_focused_shortcut) { :Enter }

        it_behaves_like 'opening focused items'
      end
    end
  end

  describe 'movement-keys' do
    shared_examples_for 'pages with focus shortcuts' do
      describe 'the up shortcut' do
        context 'on a freshly loaded page' do
          it 'focuses the first focusable' do
            press_key('k')
            classes = all('[data-keyboard-focusable]')
                      .first[:class]
                      .split(' ')
            expect(classes).to include focused_class
          end
        end

        it 'stops moving the focus when on first focusable' do
          press_key('k')
          press_key('k')
          classes = all('[data-keyboard-focusable]')
                    .first[:class]
                    .split(' ')
          expect(classes).to include focused_class
        end

        it 'moves to the previous focusable' do
          press_key('j')
          press_key('j')
          press_key('j')
          press_key('k')
          press_key('k')
          classes = all('[data-keyboard-focusable]')
                    .first[:class]
                    .split(' ')
          expect(classes).to include focused_class
        end
      end

      describe 'the down shortcut' do
        context 'on a freshly loaded page' do
          it 'focuses the first focusable' do
            press_key('j')
            classes = all('[data-keyboard-focusable]')
                      .first[:class]
                      .split(' ')
            expect(classes).to include focused_class
          end
        end

        it 'moves the focus to the next focusable' do
          press_key('j')
          press_key('j')
          classes = all('[data-keyboard-focusable]')[1][:class] .split(' ')
          expect(classes).to include focused_class
        end

        it 'stops moving focus when it reaches last focusable' do
          num_focusables = all('[data-keyboard-focusable]').length
          num_focusables.times do
            press_key('j')
          end
          # hit the shortcut once after reaching end of list
          press_key('j')
          classes = all('[data-keyboard-focusable]').last[:class] .split(' ')
          expect(classes).to include focused_class
        end
      end

      it 'focuses first focusable with "gg" shortcut' do
        press_key('g')
        press_key('g')
        classes = all('[data-keyboard-focusable]').first[:class] .split(' ')
        expect(classes).to include focused_class
      end

      it 'focuses last focusable with "G" shortcut' do
        press_key('G')
        classes = all('[data-keyboard-focusable]').last[:class] .split(' ')
        expect(classes).to include focused_class
      end
    end

    context 'when on project index page' do
      before do
        create_many_seed_projects!
        visit root_path
      end

      it_behaves_like 'pages with focus shortcuts'
    end

    context 'when on project show page' do
      before do
        click_on 'Projects'
        click_on 'foobarbaz'
      end

      it_behaves_like 'pages with focus shortcuts'
    end
  end

  describe 'shortcuts for dealing with snapshots' do
    let(:test_project) do
      create :project, :with_snapshots, name: 'test-project-with-sweep'
    end
    let(:first_snapshot) { test_project.sweeps.first.snapshots.first }
    let(:middle_snapshot) { test_project.sweeps.first.snapshots[1] }
    let(:last_snapshot) { test_project.sweeps.first.snapshots.last }

    before do
      visit snapshot_path(id: first_snapshot)
    end

    describe 'navigating snapshots' do
      context 'on the first snapshot' do
        it 'moves to next snapshot with "]"' do
          press_key(']')
          expect(page).to have_content 'Snapshot'
          expect(page).to have_content 'www1.example.org'
          expect(current_path).to eq snapshot_path(id: middle_snapshot)
        end

        it 'stays on the first snapshot with "["' do
          press_key('[')
          expect(page).to have_content 'Snapshot'
          expect(page).to have_content 'www2.example.org'
          expect(current_path).to eq snapshot_path(id: first_snapshot)
        end
      end

      context 'on the last snapshot' do
        before do
          visit snapshot_path(id: last_snapshot)
        end

        it 'goes to previous snapshot with "["' do
          press_key('[')
          expect(page).to have_content 'Snapshot'
          expect(page).to have_content 'www1.example.org'
          expect(current_path).to eq snapshot_path(id: middle_snapshot)
        end

        it 'stays on the last snapshot with "]"' do
            press_key(']')
            expect(page).to have_content 'Snapshot'
            expect(page).to have_content 'www0.example.org'
            expect(current_path).to eq snapshot_path(id: last_snapshot)
        end
      end
    end

    describe 'flipping between diffs with "x" shortcut' do
      it 'begins on diff view' do
        expect(page).to have_css('li.active a', text: 'Diff')
      end

      it 'switches from diff to before and then to after' do
        press_key('x')
        expect(page).to have_css('li.active a', text: 'Before')
        press_key('x')
        expect(page).to have_css('li.active a', text: 'After')
      end
    end

    describe 'accepting and rejecting snapshots' do
      context 'with snapshot that has diff' do
        it 'begins as neither accepted nor rejected' do
          expect(page).not_to have_content 'Accepted'
          expect(page).not_to have_content 'Rejected'
        end

        it 'is accepted with "a" shortcut' do
          press_key('a')
          expect(page).to have_content 'Accepted'
          expect(first_snapshot.reload).to be_accepted
        end

        it 'is accepted with "r" shortcut' do
          press_key('r')
          expect(page).to have_content 'Rejected'
          expect(first_snapshot.reload).to be_rejected
        end
      end
    end
  end

  # Helper Methods:
  def press_key(key_str)
    find('body').native.send_keys(key_str)
  end

  def create_many_seed_projects!
    3.times do |i|
      create(:project, name: "project #{i}")
    end
  end

  def create_seed_project!(proj_name)
    proj = create(:project, { name: proj_name })
    5.times do |i|
      create(:url, address: "http://www#{i}.example.org", project: proj)
    end
  end
end

