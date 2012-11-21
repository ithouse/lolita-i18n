require 'spec_helper'

describe Lolita::I18n::Configuration do 
  subject { described_class.new }
  let(:redis){ double("redis", :ping => true) }

  it "should load rails if Rails is defined" do 
    Lolita.stub(:rails3?).and_return(true)
    subject.should_receive(:require).with('lolita-i18n/rails')
    subject.load_rails!
  end

  it "should allow to assign store with Hash as connection options" do 
    Redis.should_receive(:new).with({:key => "value"}).and_return(redis)
    subject.store = {:key => "value"}
  end

  it "should allow to assign store as store itself" do 
    subject.store = redis 
    subject.store.should eq(redis)
  end

  it "should return assigned store" do 
    subject.store = redis
    subject.store.should eq(redis)
  end

  it "should return new Redis connection and warn when no store is assigned"  do 
    Redis.should_receive(:new).and_return(redis)
    subject.should_receive(:warn).with("Lolita::I18n No store specified. See Lolita::I18n")
    subject.store.should eq(redis)
  end

  it "should lazy create and return backend" do 
    Redis.should_receive(:new).and_return(redis)
    ::I18n::Backend::KeyValue.should_receive(:new).with(redis)
    subject.backend
  end

  it "should load translations" do 
    yaml_backend = double("yaml_backend")
    subject.yaml_backend = yaml_backend
    yaml_backend.should_receive(:load_translations)
    subject.load_translations
  end

  it "should initialize chain" do 
    subject.yaml_backend = double("yaml backend")
    Redis.stub(:new).and_return(redis)
    ::I18n::Backend::Chain.should_receive(:new).with(subject.backend,subject.yaml_backend)
    subject.initialize_chain
    Redis.unstub(:new)
  end
  
  describe "#connect" do
    before(:each){ Redis.stub(:new).and_return(redis) }
    after(:each){ Redis.unstub(:new) }

    it "should call reconnect if not connected" do
      subject.should_receive(:initialize_chain).once
      subject.connect
      subject.connect
    end

    it "should return true when success" do
      subject.connect.should be_true
    end

    it "should return not be true when fail" do
      Redis.stub(:new).and_raise(Errno::ECONNREFUSED)
      subject.connect.should_not be_true
    end
  end
  
  describe "#reconnect" do
    it "should call init if not initialized jet" do
      subject.should_receive(:init).once
      subject.reconnect
    end

    it "should not call init if already initialized" do
      subject.reconnect
      subject.should_not_receive(:init)
      subject.reconnect
    end

    it "should return true when success" do
      subject.reconnect.should be_true
    end

    it "should return false when fail" do
      Redis.stub(:new).and_raise(Errno::ECONNREFUSED)
      subject.reconnect.should_not be_true
      Redis.unstub(:new)
    end

    it "should initialize chain" do
      subject.should_receive(:initialize_chain).twice
      subject.reconnect
      subject.reconnect
    end

    it "should disconnect" do
      subject.should_receive(:disconnect)
      subject.reconnect
    end
  end
  
  describe "#disconnect" do
    it "should disconnect if connected" do
      subject.store.client.should_receive(:disconnect)
      subject.connect
      subject.disconnect
    end

    it "should not disconnect if not connected"do
      subject.store.client.should_not_receive(:disconnect)
      subject.disconnect
    end
  end

  describe "#init" do
    it "should call all propper methods" do
      subject.should_receive(:include_modules)
      subject.should_receive(:set_yaml_backend)
      subject.should_receive(:connect)
      subject.init
    end

    it "should run only once" do
      subject.should_receive(:include_modules).once
      subject.should_receive(:set_yaml_backend).once
      subject.should_receive(:connect).once
      subject.init
      subject.init
    end
  end
  
  describe "#include_modules" do
    it "include module in ::I18n::Backend::Simple" do 
      subject.include_modules
      ::I18n::Backend::Simple.ancestors.should include(::I18n::Backend::Flatten)
      ::I18n::Backend::Simple.ancestors.should include(::I18n::Backend::Pluralization)
      ::I18n::Backend::Simple.ancestors.should include(::I18n::Backend::Metadata)
      ::I18n::Backend::Simple.ancestors.should include(::I18n::Backend::InterpolationCompiler)
    end
  end

end