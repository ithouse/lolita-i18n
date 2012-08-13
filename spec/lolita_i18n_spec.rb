require 'spec_helper'

describe Lolita::I18n do 
  describe "loaded" do 
    it "should check Redis connection after Lolita.setup" do 
      Lolita.i18n.should_receive(:yaml_backend=).and_return(double())
      Lolita.i18n.should_receive(:include_modules).and_return(true)
      chain = double("chain")
      Lolita.i18n.should_receive(:initialize_chain).and_return(chain)
      redis = double("redis")
      Redis.stub(:new).and_return(redis)
      redis.stub(:ping => true)
      ::I18n.should_receive(:backend=).with(chain)
      
      Lolita.setup{}
    end

    it "should warn when Redis is not available" do 
      Lolita.i18n.should_receive(:yaml_backend=).and_return(double())
      Lolita.i18n.should_receive(:include_modules).and_return(true)
      redis = double("redis")
      Redis.stub(:new).and_return(redis)
      redis.stub(:ping).and_raise(Errno::ECONNREFUSED)
      
      Lolita.setup{}
    end

    it "should add #i18n to Lolita configuration" do 
      Lolita.configuration.should respond_to(:i18n)
    end

    it "should have Request,Redis_Configuration,Exceptions constants in module" do 
      Lolita::I18n::Abstract_Configuration.should be_kind_of(Class)
      Lolita::I18n::Abstract_Store.should be_kind_of(Class)
      Lolita::I18n::Exceptions.should be_kind_of(Module)
    end
  end
end