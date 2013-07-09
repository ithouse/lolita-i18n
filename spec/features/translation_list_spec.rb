require 'spec_helper'

describe "Viewing all translations", :redis => true, :js => true do 
  before(:each) do 
    visit "/lolita/i18n"
  end

  it "User see translations in default language and same translation in other language" do 
    within(".i18n-box .list>table>thead") do 
      page.should have_selector("th", :text => "English")
      page.should have_selector("th>select option[selected]", :text => "Latvian")
    end
  end

  it "User can switch to other language" do
    within(".i18n-box .list>table>thead") do 
      page.select("Russian", :from => "active_locale")
    end
    page.should have_selector("th select option[selected]", :text => "Russian")
  end

  it "User can view only untranslated" do 
    page.should have_selector("textarea", :text => "Virsraksts")
    page.check("show_untranslated")
    page.should have_selector("textarea", :text => "Other")
    page.should_not have_selector("textarea", :text => "Virsraksts")
  end

  it "User can sort original translation in ascending order" do 
    last_trans = page.evaluate_script("$('textarea:last').val()");
    last_trans.should_not eq("zzzz")
    click_link("translation_sort_link")
    new_last_trans = page.evaluate_script("$('textarea:last').val()");
    new_last_trans.should eq("zzzz")
  end
end