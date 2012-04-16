require 'spec_helper'

describe Lolita::I18n::Request do 

  describe Lolita::I18n::Request::Validator do 
    let(:validator){Lolita::I18n::Request::Validator.new}

    it "should validate string and return error when original and given values interpolations doesn't match" do
      ::I18n.stub(:t).and_return("original text")
      expect{validator.validate("text_key","text")}.not_to raise_error

      ::I18n.stub(:t).and_return("text with %{interpolation}")
      expect{
        validator.validate("text_key","text")
      }.to raise_error(Lolita::I18n::Exceptions::MissingInterpolationArgument)
    end

    it "should validate array's each value as string" do 
      ::I18n.stub(:t).and_return(["a","b","c"])
      expect{validator.validate("array_key",["1","2","3"])}.not_to raise_error

      ::I18n.stub(:t).and_return(["a","%{b}","c"])
      expect{
        validator.validate("array_key",["1","2","3"])
      }.to raise_error(Lolita::I18n::Exceptions::MissingInterpolationArgument,"Translation should contain all these variables %{b}")
    end

    it "should validate hash's each value as string" do 
      ::I18n.stub(:t).and_return({:a => "1", :b => "2"})
      expect{validator.validate("array_key",{"a" => "a", "b" => "b"})}.not_to raise_error

      ::I18n.stub(:t).and_return({:a => "1", :b => "2 %{count}"})
      expect{
        validator.validate("array_key",{"a" => "a", "b" => "b"})
      }.to raise_error(Lolita::I18n::Exceptions::MissingInterpolationArgument)
    end
  end

  describe Lolita::I18n::Request::Translation do 
    let(:klass){Lolita::I18n::Request::Translation}

    it "should create new with key and translation as Array,Hash or String" do 
      expect{
        Lolita::I18n::Request::Translation.new("key","value")
        Lolita::I18n::Request::Translation.new("key", ["value"])
        Lolita::I18n::Request::Translation.new("key", {:hkey => "value"})
      }.not_to raise_error
    end

    it "should return parsed value" do 
      t = klass.new("key","value")
      t.value.should eq("value")
    end

    it "should return locale for key" do 
      t = klass.new("lv.key","value")
      t.locale.should eq(:lv)
    end

    it "should return key" do 
      t = klass.new("lv.key","value")
      t.key.should eq("key")
    end

    it "should return array for store with locale, key => value and configuration hash" do 
      t = klass.new("lv.my.key","value")
      t.for_store.should eq([:lv,{"my.key" => "value"}, {:escape => false}])
    end

    it "should return original translation of given key" do 
      ::I18n.stub(:t).with(kind_of(String), kind_of(Hash)).and_return("original")
      t = klass.new("ru.my.key","value")
      t.original.should eq("original")
    end
  end


  describe Lolita::I18n::Request::Translations do 
    let(:klass){Lolita::I18n::Request::Translations}

    it "should create new with hash" do 
      expect{
        klass.new({})
      }.not_to raise_error
    end

    it "should detect if value is final and should't be flattened any more" do
      t = klass.new({})
      t.final_value?(1).should be_true
      t.final_value?([]).should be_true
      t.final_value?({:other => "other", :one => "one"}).should be_true
      t.final_value?({:other => "other"}).should be_false
      t.final_value?({:other => [], :one => 1}).should be_false
      t.final_value?({:other => {}, :one => 1}).should be_false
    end

    it "should return default translation value for different original values" do 
      t = klass.new({})
      ::I18n.stub(:t).and_return([])
      t.translation_value("key",[1,2],"ru").should eq([])
      ::I18n.stub(:t).and_return({})
      t.translation_value("key",{:a=>1},"ru").should eq({})
      ::I18n.stub(:t).and_return("translation")
      t.translation_value("key","value","ru").should eq("translation")
      ::I18n.stub(:t).and_return([1,2])
      t.translation_value("key",[2,3],"ru").should eq([1,2])
    end

    it "should normalize for locale" 

    it "should flatten keys until Array is found or Hash with counts" 

  end

  it "should create new request with params" 

  it "should return translations" 

  it "should update key"

  it "should have validator"

  it "should delete key"

end