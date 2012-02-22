# coding: utf-8

USE_RAILS=true unless defined?(USE_RAILS)
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

include Lolita::Test::Matchers

describe Lolita::I18nController do
  render_views

  it "should have i18n routes" do
    {:get=>"/lolita/i18n"}.should be_routable
    {:put=>"/lolita/i18n/1"}.should be_routable
    {:put=>"/lolita/i18n/translate_untranslated"}.should be_routable
    {:get=>"/lolita/i18n"}.should be_routable
  end

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