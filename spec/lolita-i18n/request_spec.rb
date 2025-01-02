require 'spec_helper'

describe Lolita::I18n::Request do 

  describe Lolita::I18n::Request::Validator do 
    let(:validator){Lolita::I18n::Request::Validator.new}

    it "should validate string and return error when original and given values interpolations doesn't match" do
      allow(::I18n).to receive(:t).and_return("original text")
      expect{validator.validate("text_key","text")}.not_to raise_error

      allow(::I18n).to receive(:t).and_return("text with %{interpolation}")
      expect{
        validator.validate("text_key","text")
      }.to raise_error(Lolita::I18n::Exceptions::MissingInterpolationArgument)
    end

    it "should validate array's each value as string" do 
      allow(::I18n).to receive(:t).and_return(["a","b","c"])
      expect{validator.validate("array_key",["1","2","3"])}.not_to raise_error

      allow(::I18n).to receive(:t).and_return(["a","%{b}","c"])
      expect{
        validator.validate("array_key",["1","2","3"])
      }.to raise_error(Lolita::I18n::Exceptions::MissingInterpolationArgument,"Translation should contain all these variables %{b}")
    end

    it "should validate hash's each value as string" do 
      allow(::I18n).to receive(:t).and_return({:a => "1", :b => "2"})
      expect{validator.validate("array_key",{"a" => "a", "b" => "b"})}.not_to raise_error

      allow(::I18n).to receive(:t).and_return({:a => "1", :b => "2 %{count}"})
      expect{
        validator.validate("array_key",{"a" => "a", "b" => "b"})
      }.to raise_error(Lolita::I18n::Exceptions::MissingInterpolationArgument)
    end

    it "should raise error when translation is Array but original is not or sizes does not match" do 
      allow(::I18n).to receive(:t).and_return("")
      expect{
        validator.validate("key",[1,2])
      }.to raise_error(Lolita::I18n::Exceptions::TranslationDoesNotMatch)

      allow(::I18n).to receive(:t).and_return([1,2])
      expect{
        validator.validate("key",[2])
      }
    end

    it "should raise error when translation is Hash but original is not or keys does not match " do 
      allow(::I18n).to receive(:t).and_return("")
      expect{
        validator.validate("key",{"a" => 1})
      }.to raise_error(Lolita::I18n::Exceptions::TranslationDoesNotMatch)
      allow(::I18n).to receive(:t).and_return({:a => 2, :b => 3})
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
      allow(I18n).to receive(:t).and_return("original_value")
      t = klass.new("key","value")
      expect(t.value).to eq("value")
    end

    it "should return locale for key" do 
      t = klass.new("lv.key","value")
      expect(t.locale).to eq(:lv)
    end

    it "should return key" do 
      t = klass.new("lv.key","value")
      expect(t.key).to eq("key")
    end

    it "should return array for store with locale, key => value and configuration hash" do 
      t = klass.new("lv.my.key","value")
      expect(t.for_store).to eq([:lv,{"my.key" => "value"}, {:escape => false}])
    end

    it "should return original translation of given key" do 
      allow(::I18n).to receive(:t).with(kind_of(String), kind_of(Hash)).and_return("original")
      t = klass.new("ru.my.key","value")
      expect(t.original).to eq("original")
    end
  end


  describe Lolita::I18n::Request::Translations do 
    before(:each) do 
      ::I18n.locale = :en
    end

    let(:klass){Lolita::I18n::Request::Translations}
    let(:translations) {
      allow(::I18n).to receive(:t) do |*args|
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
      expect(t.final_value?(1)).to be_truthy
      expect(t.final_value?([])).to be_truthy
      expect(t.final_value?({:other => "other", :one => "one"})).to be_truthy
      expect(t.final_value?({:other => "other"})).to be_falsey
      expect(t.final_value?({:other => [], :one => 1})).to be_falsey
      expect(t.final_value?({:other => {}, :one => 1})).to be_falsey
    end

    it "should return default translation value for different original values" do 
      t = klass.new({})
      allow(::I18n).to receive(:t).and_return([])
      expect(t.translation_value("key",[1,2],"ru")).to eq([])
      allow(::I18n).to receive(:t).and_return({})
      expect(t.translation_value("key",{:a=>1},"ru")).to eq({})
      allow(::I18n).to receive(:t).and_return("translation")
      expect(t.translation_value("key","value","ru")).to eq("translation")
      allow(::I18n).to receive(:t).and_return([1,2])
      expect(t.translation_value("key",[2,3],"ru")).to eq([1,2])
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
      expect(result).to eq(valid_results)
    end 

    it "should normalize for locale" do
      t = klass.new(translations)
      valid_results = {
        :arr => {:translation => [], :original_translation => [1,2], :url => nil},
        :str => {:translation => "-no-translation-", :original_translation => "string", :url => nil},
        :inter => {:translation => {}, :original_translation => {:one => "one", :other => "other"}, :url => nil},
        :"hsh.key" => {:translation => "-no-translation-", :original_translation => "value", :url => nil}
      }
      expect(t.normalized(:lv)).to eq(valid_results)
    end

    it "should normalize for locale end retur registerd URL" do
      allow_any_instance_of(Redis).to receive(:get).and_return '/kekss'
      t = klass.new(translations)
      valid_results = {
        :arr => {:translation => [], :original_translation => [1,2], :url => '/kekss'},
        :str => {:translation => "-no-translation-", :original_translation => "string", :url => '/kekss'},
        :inter => {:translation => {}, :original_translation => {:one => "one", :other => "other"}, :url => '/kekss'},
        :"hsh.key" => {:translation => "-no-translation-", :original_translation => "value", :url => '/kekss'}
      }
      expect(t.normalized(:lv)).to eq(valid_results)
    end
  end

  let(:request_klass){Lolita::I18n::Request}

  it "should create new request with params" do 
    expect{
      request = request_klass.new({:a => 1})
      expect(request.params).to eq({:a => 1})
    }.not_to raise_error
  end

  it "should return translations" do 
    r = request_klass.new({})
    expect(Lolita.i18n).to receive(:load_translations).and_return(true)
    allow(Lolita.i18n).to receive(:yaml_backend).and_return(double(:translations => {:en => {}}))
    expect_any_instance_of(Lolita::I18n::Request::Translations).to receive(:normalized).once
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
      [:"key8", {:original_translation => [1,2]}],
      [:"key7", {:original_translation => {:a => 1}}],
      [:"key5", {:original_translation => nil}],
      [:"key6", {:original_translation => "aaa"}],
      [:"key3", {:original_translation => false}],
      [:"key4", {:original_translation => true}], 
      [:"key9", {:original_translation => "ZZZ"}]
    ]
    expect(r.sort_translations(unsorted_translations)).to eq(sorted_translations)
  end

  it "should update key" do 
    r = request_klass.new({:translation => "translation", :id => Base64.encode64("ru.key")})
    allow(::I18n).to receive(:t).and_return("original")
    backend = double("backend")
    Lolita.i18n.stub(:backend => backend)
    expect(backend).to receive(:store_translations).with(:"ru", { "key" => "translation" }, :escape => false).and_return(true)
    r.update_key
  end

  it "should have validator" do 
    r = request_klass.new({})
    expect(r.validator).to be_a_kind_of(Lolita::I18n::Request::Validator)
  end

 
end
