require 'spec_helper'

describe Lolita::I18n::Configuration do
  subject { described_class.new }
  let(:redis){ double("redis", :ping => true, client: double(disconnect: true, reconnect: true)) }

  it "should load rails if Rails is defined" do
    Lolita.stub(:rails?).and_return(true)
    subject.should_receive(:require).with('lolita-i18n/rails')
    subject.load_rails!
  end

  it "should allow to assign store with Hash as connection options" do
    expect(Redis).to receive(:new).with({:key => "value"}).and_return(redis)
    subject.store = {:key => "value"}
  end

  it "should allow to assign store as store itself" do
    subject.store = redis
    expect(subject.store).to eq(redis)
  end

  it "should return assigned store" do
    subject.store = redis
    expect(subject.store).to eq(redis)
  end

  it "should return new Redis connection and warn when no store is assigned"  do
    expect(Redis).to receive(:new).and_return(redis)
    expect(subject).to receive(:warn).with("Lolita::I18n No store specified. See Lolita::I18n")
    expect(subject.store).to eq(redis)
  end

  it "should lazy create and return backend" do
    expect(Redis).to receive(:new).and_return(redis)
    expect(::I18n::Backend::KeyValue).to receive(:new).with(redis)
    subject.backend
  end

  it "should load translations" do
    yaml_backend = double("yaml_backend")
    subject.yaml_backend = yaml_backend
    expect(yaml_backend).to receive(:load_translations)
    subject.load_translations
  end

  it "should initialize chain" do
    subject.yaml_backend = double("yaml backend")
    allow(Redis).to receive(:new).and_return(redis)
    expect(::I18n::Backend::Chain).to receive(:new).with(subject.backend,subject.yaml_backend)
    subject.initialize_chain
    allow(Redis).to receive(:new).and_call_original
  end

  describe "#connect" do
    before(:each){ allow(Redis).to receive(:new).and_return(redis) }
    after(:each){ allow(Redis).to receive(:new).and_call_original }

    it "should call reconnect if not connected" do
      expect(subject).to receive(:initialize_chain).once
      subject.connect
      subject.connect
    end

    it "should return true when success" do
      expect(subject.connect).to be_truthy
    end

    it "should return not be true when fail" do
      allow(Redis).to receive(:new).and_raise(Errno::ECONNREFUSED)
      expect(subject.connect).not_to be_truthy
    end
  end

  describe "#reconnect" do
    it "should call init if not initialized jet" do
      expect(subject).to receive(:init).once
      subject.reconnect
    end

    it "should not call init if already initialized" do
      subject.reconnect
      expect(subject).not_to receive(:init)
      subject.reconnect
    end

    it "should return true when success" do
      expect(subject.reconnect).to be_truthy
    end

    it "should return false when fail" do
      allow(Redis).to receive(:new).and_raise(Errno::ECONNREFUSED)
      expect(subject.reconnect).not_to be_truthy
      allow(Redis).to receive(:new).and_call_original
    end

    it "should initialize chain" do
      expect(subject).to receive(:initialize_chain).twice
      subject.reconnect
      subject.reconnect
    end

    it "should disconnect" do
      expect(subject).to receive(:disconnect)
      subject.reconnect
    end
  end

  describe "#disconnect" do
    it "should disconnect if connected" do
      expect(subject.store).to receive(:disconnect!).once
      subject.connect
      subject.disconnect
    end

    it "should not disconnect if not connected"do
      expect(subject.store).not_to receive(:disconnect!)
      subject.disconnect
    end
  end

  describe "#init" do
    it "should call all propper methods" do
      expect(subject).to receive(:include_modules)
      expect(subject).to receive(:set_yaml_backend)
      expect(subject).to receive(:connect)
      subject.init
    end

    it "should run only once" do
      expect(subject).to receive(:include_modules).once
      expect(subject).to receive(:set_yaml_backend).once
      expect(subject).to receive(:connect).once
      subject.init
      subject.init
    end
  end

  describe "#include_modules" do
    it "include module in ::I18n::Backend::Simple" do
      subject.include_modules
      expect(::I18n::Backend::Simple.ancestors).to include(::I18n::Backend::Flatten)
      expect(::I18n::Backend::Simple.ancestors).to include(::I18n::Backend::Pluralization)
      expect(::I18n::Backend::Simple.ancestors).to include(::I18n::Backend::InterpolationCompiler)
    end
  end

end
