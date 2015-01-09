require "spec_helper"

describe "Lolita I18n routes", :rails => true do 
  it "has route for update with key" do 
    expect({:put => "/lolita/i18n/my_id"}).to route_to(:controller => "lolita/i18n", :action => "update", :id => "my_id")
  end

  it "has route for list of all translations" do 
    expect({:get => "/lolita/i18n"}).to route_to(:controller => "lolita/i18n", :action => "index")
  end
end 