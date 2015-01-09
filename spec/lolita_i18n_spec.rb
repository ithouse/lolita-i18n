require 'spec_helper'

describe Lolita::I18n do 
  describe "loaded" do 
    
    it "should check Redis connection after Lolita.setup" do 
      expect(Lolita.i18n).to receive(:init)
      Lolita.setup{}
    end

    it "should add #i18n to Lolita configuration" do 
      expect(Lolita.configuration).to respond_to(:i18n)
    end

    it "should have Request,Configuration,Exceptions constants in module" do 
      expect(Lolita::I18n::Request).to be_kind_of(Class)
      expect(Lolita::I18n::Configuration).to be_kind_of(Class)
      expect(Lolita::I18n::Exceptions).to be_kind_of(Module)
    end
  end
end