require 'spec_helper'

describe 'Keyboard Shortcuts' do
  without_transactional_fixtures do
    let(:focused_class) { 'keyboard-focused' }

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
      5.times do
        create(:url, project: proj)
      end
    end

    before do
      visit root_path
    end

    it 'should open the help modal with the "?" shortcut', :js => true do
      press_key('?')
      expect(page).to have_content 'Keyboard shortcuts'
    end

    describe 'movement-keys' do
      shared_examples_for 'pages with focus shortcuts' do
        describe 'the up shortcut' do
          context 'on a freshly loaded page' do
            it 'focuses the first focusable', :js => true do
              press_key('k')
              classes = all('[data-keyboard-focusable]')
                        .first[:class]
                        .split(' ')
              expect(classes).to include focused_class
            end
          end

          it 'stops moving the focus when on first focusable', :js => true do
            press_key('k')
            press_key('k')
            classes = all('[data-keyboard-focusable]')
                      .first[:class]
                      .split(' ')
            expect(classes).to include focused_class
          end

          it 'moves to the previous focusable', :js => true do
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
            it 'focuses the first focusable', :js => true do
              press_key('j')
              expect(all('[data-keyboard-focusable]').first[:class]).to eq focused_class
            end
          end

          it 'moves the focus to the next focusable', :js => true do
            press_key('j')
            press_key('j')
            expect(all('[data-keyboard-focusable]')[1][:class]).to eq focused_class
          end

          it 'stops moving focus when it reaches last focusable', :js => true do
            num_focusables = all('[data-keyboard-focusable]').length
            num_focusables.times do
              press_key('j')
            end
            # hit the shortcut once after reaching end of list
            press_key('j')
            expect(all('[data-keyboard-focusable]').last[:class]).to eq focused_class
          end
        end

        it 'focuses first focusable with "gg" shortcut', :js => true do
          press_key('g')
          press_key('g')
          expect(all('[data-keyboard-focusable]').first[:class]).to eq focused_class
        end

        it 'focuses last focusable with "G" shortcut', :js => true do
          press_key('G')
          expect(all('[data-keyboard-focusable]').last[:class]).to eq focused_class
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
          create_seed_project!('foobarbaz')
          click_on 'Projects'
          click_on 'foobarbaz'
        end

        it_behaves_like 'pages with focus shortcuts'
      end
    end
  end
end
