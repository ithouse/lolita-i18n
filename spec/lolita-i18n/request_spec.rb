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

    it "should raise error when translation is Array but original is not or sizes does not match" do 
      ::I18n.stub(:t).and_return("")
      expect{
        validator.validate("key",[1,2])
      }.to raise_error(Lolita::I18n::Exceptions::TranslationDoesNotMatch)

      ::I18n.stub(:t).and_return([1,2])
      expect{
        validator.validate("key",[2])
      }
    end

    it "should raise error when translation is Hash but original is not or keys does not match " do 
      ::I18n.stub(:t).and_return("")
      expect{
        validator.validate("key",{"a" => 1})
      }.to raise_error(Lolita::I18n::Exceptions::TranslationDoesNotMatch)
      ::I18n.stub(:t).and_return({:a => 2, :b => 3})
      expect{
        validator.validate("key",{"a" => 1})
      }
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
    before(:each) do 
      ::I18n.locale = :en
    end

    let(:klass){Lolita::I18n::Request::Translations}
    let(:translations) {
      ::I18n.stub(:t) do |*args|
        if args[1] && args[1][:locale] == :en
          if args[0] == :arr
            [1,2] 
          elsif args[0] == :str
            "string"
          elsif args[0] == :inter
            {:one => "one",:other => "other"} 
          elsif args[0] == :"hsh.key"
            "value" 
          end
        else
          "-no-translation-"
        end
      end
      {:arr => [1,2], :str => "string", :inter => {:one => "one",:other => "other"}, :hsh => {:key => "value"}}
    }

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

    it "should flatten keys until final value is found" do 
      t = klass.new({})
      result = []
      t.flatten_keys(translations, :lv) do |key,translation_value,original_value|
        result << [key,translation_value,original_value]
      end
      valid_results = [
        [:arr, [], [1,2]],
        [:str, "-no-translation-", "string"],
        [:inter, {}, {:one => "one", :other => "other"}],
        [:"hsh.key","-no-translation-", "value"]
      ]
      result.should eq(valid_results)
    end 

    it "should normalize for locale" do 
      t = klass.new(translations)
      valid_results = {
        :arr => {:translation => [], :original_translation => [1,2]},
        :str => {:translation => "-no-translation-", :original_translation => "string"},
        :inter => {:translation => {}, :original_translation => {:one => "one", :other => "other"}},
        :"hsh.key" => {:translation => "-no-translation-", :original_translation => "value"}
      }
      t.normalized(:lv).should eq(valid_results)
    end

  end

  let(:request_klass){Lolita::I18n::Request}

  it "should create new request with params" do 
    expect{
      request = request_klass.new({:a => 1})
      request.params.should eq({:a => 1})
    }.not_to raise_error
  end

  it "should return translations" do 
    r = request_klass.new({})
    Lolita.i18n.should_receive(:load_translations).and_return(true)
    Lolita.i18n.stub(:yaml_backend).and_return(stub(:translations => {:en => {}}))
    Lolita::I18n::Request::Translations.any_instance.should_receive(:normalized).once
    r.translations(:en)
  end

  it "should sort translations" do 
    r = request_klass.new({})
    unsorted_translations = {
      :"key9" => {:original_translation => "ZZZ"},
      :"key8" => {:original_translation => [1,2]},
      :"key7" => {:original_translation => {:a => 1}},
      :"key6" => {:original_translation => "aaa"},
      :"key5" => {:original_translation => nil},
      :"key4" => {:original_translation => true}, 
      :"key3" => {:original_translation => false}
    }
    sorted_translations = [
      [:"key7", {:original_translation => {:a => 1}}],
      [:"key8", {:original_translation => [1,2]}],
      [:"key5", {:original_translation => nil}],
      [:"key6", {:original_translation => "aaa"}],
      [:"key3", {:original_translation => false}],
      [:"key4", {:original_translation => true}], 
      [:"key9", {:original_translation => "ZZZ"}]
    ]
    r.sort_translations(unsorted_translations).should eq(sorted_translations)
  end

  it "should update key" do 
    r = request_klass.new({:translation => "translation", :id => Base64.encode64("ru.key")})
    ::I18n.stub(:t).and_return("original")
    backend = double("backend")
    Lolita.i18n.stub(:backend => backend)
    backend.should_receive(:store_translations).with(:"ru", { "key" => "translation" }, :escape => false).and_return(true)
    r.update_key
  end

  it "should have validator" do 
    r = request_klass.new({})
    r.validator.should be_a_kind_of(Lolita::I18n::Request::Validator)
  end

  it "should delete key" do 
    r = request_klass.new({:translation => "", :id => Base64.encode64("ru.key")})
    store = double("store")
    Lolita.i18n.stub(:store => store)
    store.should_receive(:del).with("ru.key").twice
    r.del "ru.key"
    r.update_key
  end

end