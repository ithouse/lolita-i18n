require 'spec_helper'

describe Lolita::I18nController, type: :controller do

  describe "GET index" do 
    it "should authorize resource" do
      expect(controller.authorization_proxy).to receive(:authorize!).with(:read,controller.resource_class)
      get :index
    end

    it "should assign all translations to variable" do 
      get :index
      expect(assigns[:translations]).to be_kind_of(Hash)
    end

    it "should sort translations when params[:sort] is equal to 1" do 
      i18n_request = double("i18n_request")
      allow(i18n_request).to receive(:translations)
      controller.stub(:i18n_request => i18n_request)
      expect(i18n_request).not_to receive(:sort_translations)
      get :index
      i18n_request = double("i18n_request2")
      allow(i18n_request).to receive(:translations)
      controller.stub(:i18n_request => i18n_request)
      expect(i18n_request).to receive(:sort_translations)
      get :index, params: { sort: 1 }
    end
  end

  describe "PUT update" do 
    it "should authorize resource for update" do 
      expect(controller.authorization_proxy).to receive(:authorize!).with(:update,controller.resource_class)
      put :update, params: { id: "key", translation: "translation", format: :json }
    end

    it "should create notice when save is successful" do 
      controller.stub(:i18n_request => double(:update_key => true))
      expect(controller).to receive(:notice).with(kind_of(String))
      put :update, params: { id: Base64.encode64("lv.title"), translation: "Tulkots virsraksts", format: :json }
    end

    it "should create error when save is unsuccessful" do 
      controller.stub(:i18n_request => double(:update_key => false))
      expect(controller).to receive(:error).with(kind_of(String))
      put :update, params: { id: Base64.encode64("lv.title"), translation: "Tulkots virsraksts", format: :json }
    end

    it "should render error when Lolita::I18n::Exceptions::MissingInterpolationArgument is raised" do 
      i18n_request = double("request")
      allow(i18n_request).to receive(:update_key).and_raise(Lolita::I18n::Exceptions::MissingInterpolationArgument.new(["%{count}"]))
      controller.stub(:i18n_request => i18n_request)
      put :update, params: { id: Base64.encode64("lv.title"), translation: "Tulkots virsraksts", format: :json }
      expect(response.body).to eq(%q{{"error":"Translation should contain all these variables %{count}"}})
    end

    it "should render error when any other excption happens" do 
      i18n_request = double("request")
      allow(i18n_request).to receive(:update_key).and_raise(ArgumentError.new)
      controller.stub(:i18n_request => i18n_request)
      put :update, params: { id: Base64.encode64("lv.title"), translation: "Tulkots virsraksts", format: :json }
      expect(response.body).to eq(%q{{"error":"Key is not saved. Some error accured."}})
    end 
  end
end
