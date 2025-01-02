require 'spec_helper'

describe "Translating process" do 
   def translate_key(key)
    expect(page).to have_selector("textarea[name='#{key}']")
    fill_in(key, :with => "translation for #{key}")
    page.execute_script(%Q{$("textarea[name='#{key}']").blur()})
    page.execute_script(%Q{window.location.href='#'})
    page.check("show_untranslated")
    expect(page.find_field(key).value).to eq("translation for #{key}")
    expect(page).not_to have_content("Key is not saved")
  end

  before(:each) do 
    visit "/lolita/i18n"
  end

  describe "Translating value for default language", :rails => true, :js => true, :redis => true do 

    it "User can translate simple values" do
      translate_key("en.untranslated_title")
    end

    it "User can translate Hash values" do 
      translate_key("en.resource.one")
    end

    it "User can translate Array values" do 
      translate_key("en.numbers[0]")
    end
  end

  describe "Translating values for foreign language", :js => true, :redis => true do 
    it "User can translate simple values" do 
      translate_key("lv.untranslated_title")
    end

    it "User can translate Hash values" do 
      translate_key("lv.resource.one")
    end

    it "User can translate Array values" do 
      translate_key("lv.numbers[0]")
    end
  end
end


