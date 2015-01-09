require 'spec_helper'

describe Lolita::I18nHelper, :rails => true do 
  it "should return locale options" do 
    good_locale_options = [
      ["Choose other language",nil],
      ["Latvian",:lv],
      ["Russian",:ru],
      ["Swedish",:sv_SE]
    ]
    expect(helper.locale_options).to eq(good_locale_options)
  end

  it "#is_untranslated?" do
    expect(helper.is_untranslated?("")).to be_truthy
    expect(helper.is_untranslated?("text")).to be_falsey
    expect(helper.is_untranslated?([])).to be_truthy
    expect(helper.is_untranslated?({})).to be_truthy
  end

  it "translation is visible when value is not blank and params does not say to show only untranslated values" do 
    expect(helper.translation_visible?("", nil)).to be_truthy
    expect(helper.translation_visible?("text", nil)).to be_truthy
    expect(helper.translation_visible?([], nil)).to be_truthy
    expect(helper.translation_visible?({}, nil)).to be_truthy

    helper.params[:show_untranslated] = true
    expect(helper.translation_visible?("", nil)).to be_truthy
    expect(helper.translation_visible?("text", nil)).to be_falsey
    expect(helper.translation_visible?([], nil)).to be_truthy
    expect(helper.translation_visible?({}, nil)).to be_truthy
  end

  describe "#any_translation_visible?" do 
    it "should detect if any translation from array is visible" do 
      expect(helper.any_translation_visible?([2,1], nil)).to be_truthy
      expect(helper.any_translation_visible?([], nil)).to be_truthy

      helper.params[:show_untranslated] = true
      expect(helper.any_translation_visible?([], nil)).to be_truthy
      expect(helper.any_translation_visible?(["",1], nil)).to be_truthy
      expect(helper.any_translation_visible?(["a","b"], nil)).to be_falsey
    end


    it "should detect if any translation from hash is visible" do 
      expect(helper.any_translation_visible?({:a => "1",:b => "2" }, nil)).to be_truthy
      expect(helper.any_translation_visible?([], nil)).to be_truthy

      helper.params[:show_untranslated] = true
      expect(helper.any_translation_visible?({}, nil)).to be_truthy
      expect(helper.any_translation_visible?({:a => "1",:b => "2" }, nil)).to be_falsey
      expect(helper.any_translation_visible?({:a => "1",:b => "" }, nil)).to be_truthy
    end

    it "should call #translation_visible? for any other value" do 
      expect(helper).to receive(:translation_visible?).with("text", '/url')
      helper.any_translation_visible?("text", '/url')
    end
  end

  describe "#sort_link" do 
    before(:each) do 
      {:controller => "lolita/i18n",:action => "index", :i18n_locale => :en}.each do |k,v|
        helper.params[k] = v
      end
    end
    it "should create link with sort in it when params does not include :sort" do 
      expect(helper.sort_link).to match(/sort=1/)
    end

    it "should create link witho sort in it when params include :sort"  do 
      helper.params[:sort] = "1"
      expect(helper.sort_link).not_to match(/sort=1/)
    end
  end

end
