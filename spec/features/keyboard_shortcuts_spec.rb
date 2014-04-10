require 'spec_helper'

describe 'Keyboard Shortcuts' do
  def press_key(key_str)
    find('body').native.send_keys(key_str, :Enter)
  end

  before do
    visit root_path
  end

  it 'should open the help modal with the "?" shortcut', :js => true do
    press_key('?')
    expect(page).to have_content 'Keyboard shortcuts'
  end
end
