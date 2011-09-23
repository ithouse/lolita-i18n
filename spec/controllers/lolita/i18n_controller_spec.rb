USE_RAILS=true
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Lolita::I18nController do
  render_views

  it "should show all translations" do
    get :index
    response.should render_template("index")
    response.body.should match(/#{::I18n.t('lolita-i18n.title')}/)
  end

  it "should save translation" do
    put :update, :id=>"en.Page title",:translation=>"New title", :format => :json
    response.body.should == {error: false}.to_json
    ::I18n.t("Page title", :locale => :en).should == "New title"
  end
end