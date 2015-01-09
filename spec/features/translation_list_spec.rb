require 'spec_helper'

describe "Viewing all translations", :redis => true, :js => true do 
  before(:each) do 
    visit "/lolita/i18n"
  end

  it "User see translations in default language and same translation in other language" do 
    within(".i18n-box .list>table>thead") do 
      expect(page).to have_selector("th", :text => "English")
      expect(page).to have_selector("th>select option[selected]", :text => "Latvian")
    end
  end

  it "User can switch to other language" do
    within(".i18n-box .list>table>thead") do 
      page.select("Russian", :from => "active_locale")
    end
    expect(page).to have_selector("th select option[selected]", :text => "Russian")
  end

  it "User can view only untranslated" do 
    expect(page).to have_selector("textarea", :text => "Virsraksts")
    page.check("show_untranslated")
    expect(page).to have_selector("textarea", :text => "Other")
    expect(page).not_to have_selector("textarea", :text => "Virsraksts")
  end

  it "User can sort original translation in ascending order" do 
    last_trans = page.evaluate_script("$('textarea:last').val()");
    expect(last_trans).not_to eq("zzzz")
    click_link("translation_sort_link")
    new_last_trans = page.evaluate_script("$('textarea:last').val()");
    expect(new_last_trans).to eq("zzzz")
  end
end