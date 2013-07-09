require 'spec_helper'

describe Lolita::I18nController do 
  
  describe "GET index" do 
    it "should authorize resource" do
      controller.authorization_proxy.should_receive(:authorize!).with(:read,controller.resource_class)
      get :index
    end

    it "should assign all translations to variable" do 
      get :index
      assigns[:translations].should be_kind_of(Hash)
    end

    it "should sort translations when params[:sort] is equal to 1" do 
      i18n_request = double("i18n_request")
      i18n_request.stub(:translations)
      controller.stub(:i18n_request => i18n_request)
      i18n_request.should_not_receive(:sort_translations)
      get :index
      i18n_request = double("i18n_request2")
      i18n_request.stub(:translations)
      controller.stub(:i18n_request => i18n_request)
      i18n_request.should_receive(:sort_translations)
      get :index, :sort => 1
    end
  end

  describe "PUT update" do 
    it "should authorize resource for update" do 
      controller.authorization_proxy.should_receive(:authorize!).with(:update,controller.resource_class)
      put :update, :id => "key", :translation => "translation", :format => :json
    end

    it "should create notice when save is successful" do 
      controller.stub(:i18n_request => stub(:update_key => true))
      controller.should_receive(:notice).with(kind_of(String))
      put :update, :id => Base64.encode64("lv.title"),:translation => "Tulkots virsraksts", :format => :json
    end

    it "should create error when save is unsuccessful" do 
      controller.stub(:i18n_request => stub(:update_key => false))
      controller.should_receive(:error).with(kind_of(String))
      put :update, :id => Base64.encode64("lv.title"),:translation => "Tulkots virsraksts", :format => :json
    end

    it "should render error when Lolita::I18n::Exceptions::MissingInterpolationArgument is raised" do 
      i18n_request = double("request")
      i18n_request.stub(:update_key).and_raise(Lolita::I18n::Exceptions::MissingInterpolationArgument.new(["%{count}"]))
      controller.stub(:i18n_request => i18n_request)
      put :update, :id => Base64.encode64("lv.title"),:translation => "Tulkots virsraksts", :format => :json
      response.body.should eq(%q{{"error":"Translation should contain all these variables %{count}"}})
    end

    it "should render error when any other excption happens" do 
      i18n_request = double("request")
      i18n_request.stub(:update_key).and_raise(ArgumentError.new)
      controller.stub(:i18n_request => i18n_request)
      put :update, :id => Base64.encode64("lv.title"),:translation => "Tulkots virsraksts", :format => :json
      response.body.should eq(%q{{"error":"Key is not saved. Some error accured."}})
    end 
  end
end
