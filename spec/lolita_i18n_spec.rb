require 'spec_helper'

describe Lolita::I18n do 
  describe "loaded" do 
    
    it "should check Redis connection after Lolita.setup" do 
      Lolita.i18n.should_receive(:init)
      Lolita.setup{}
    end

    it "should add #i18n to Lolita configuration" do 
      Lolita.configuration.should respond_to(:i18n)
    end

    it "should have Request,Configuration,Exceptions constants in module" do 
      Lolita::I18n::Request.should be_kind_of(Class)
      Lolita::I18n::Configuration.should be_kind_of(Class)
      Lolita::I18n::Exceptions.should be_kind_of(Module)
    end
  end
end