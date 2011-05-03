USE_RAILS=true
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Lolita::I18nController do
  render_views

  it "should show all translations" do
    get :index
    response.should render_template("index")
    response.body.should match(/Page title/)
  end

  it "should open edit form" do
    get :edit, :id=>"en.Page title"
    response.should render_template("edit")
    response.body.should match(/Page title/)
  end

  it "should save transaltion" do
    put :update, {:id=>"en.Page title"}, {:value=>"New title"}
    response.body.should match(/New title/)
  end
end