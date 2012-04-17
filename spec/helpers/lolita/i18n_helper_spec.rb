require 'spec_helper'

describe Lolita::I18nHelper, :rails => true do 
  it "should return locale options" do 
    good_locale_options = [
      ["Choose other language",nil],
      ["Latvian",:lv],
      ["Russian",:ru]
    ]
    helper.locale_options.should eq(good_locale_options)
  end

  it "translation is visible when value is not blank and params does not say to show only untranslated values" do 
    helper.translation_visible?("").should be_true
    helper.translation_visible?("text").should be_true
    helper.translation_visible?([]).should be_true
    helper.translation_visible?({}).should be_true

    helper.params[:show_untranslated] = true
    helper.translation_visible?("").should be_true
    helper.translation_visible?("text").should be_false
    helper.translation_visible?([]).should be_true
    helper.translation_visible?({}).should be_true
  end

  describe "#any_translation_visible?" do 
    it "should detect if any translation from array is visible" do 
      helper.any_translation_visible?([2,1]).should be_true
      helper.any_translation_visible?([]).should be_true

      helper.params[:show_untranslated] = true
      helper.any_translation_visible?([]).should be_true
      helper.any_translation_visible?(["",1]).should be_true
      helper.any_translation_visible?(["a","b"]).should be_false
    end


    it "should detect if any translation from hash is visible" do 
      helper.any_translation_visible?({:a => "1",:b => "2" }).should be_true
      helper.any_translation_visible?([]).should be_true

      helper.params[:show_untranslated] = true
      helper.any_translation_visible?({}).should be_true
      helper.any_translation_visible?({:a => "1",:b => "2" }).should be_false
      helper.any_translation_visible?({:a => "1",:b => "" }).should be_true
    end

    it "should call #translation_visible? for any other value" do 
      helper.should_receive(:translation_visible?).with("text")
      helper.any_translation_visible?("text")
    end
  end

  describe "#sort_link" do 
    before(:each) do 
      {:controller => "lolita/i18n",:action => "index", :i18n_locale => :en}.each do |k,v|
        helper.params[k] = v
      end
    end
    it "should create link with sort in it when params does not include :sort" do 
      helper.sort_link.should match(/sort=1/)
    end

    it "should create link witho sort in it when params include :sort"  do 
      helper.params[:sort] = "1"
      helper.sort_link.should_not match(/sort=1/)
    end
  end

end