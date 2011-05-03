USE_RAILS=true
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

include Lolita::Test::Matchers

describe Lolita::I18n do
  it "should have i18n routes" do
    {:get=>"/lolita/i18n"}.should be_routable
    {:get=>"/lolita/i18n/1/edit"}.should be_routable
    {:put=>"/lolita/i18n/1"}.should be_routable
  end

  it "should have fallback to default I18n store" do
    I18n.backend.store["en.Page title"].gsub(/\"/,"").should == "Page title"
  end
end