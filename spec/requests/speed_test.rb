require 'spec_helper'

describe "Viewing all translations", :rails => true, :redis => true, :js => true do 

  it "should load lolita/i18n 100 times" do 

      10.times do 
    visit "/lolita/i18n"
  end
 
  end

end