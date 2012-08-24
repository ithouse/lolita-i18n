require 'spec_helper'

describe Lolita::I18n::Redis_Store do 

  let(:request_klass){Lolita::I18n::Redis_Store}

  it "should create new request with params" do 
    expect{
      request = request_klass.new
      request.params = ({:a => 1})
      request.params.should eq({:a => 1})
    }.not_to raise_error
  end

  it "should return translations" do 
    r = request_klass.new
    r.params = ({})
    Lolita.i18n.should_receive(:load_translations).and_return(true)
    Lolita.i18n.stub(:yaml_backend).and_return(stub(:translations => {:en => {}}))
    Lolita::I18n::Abstract_Store::Translations.any_instance.should_receive(:normalized).once
    r.translations(:en)
  end

  it "should sort translations" do 
    r = request_klass.new
    r.params = ({})
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
    r = request_klass.new()
    r.params = ({:translation => "translation", :id => Base64.encode64("ru.key")})
    ::I18n.stub(:t).and_return("original")
    backend = double("backend")
    Lolita.i18n.stub(:backend => backend)
    backend.should_receive(:store_translations).with(:"ru", { "key" => "translation" }, :escape => false).and_return(true)
    r.update_key(r.params)
  end

  it "should have validator" do 
    r = request_klass.new()
    r.validator.should be_a_kind_of(Lolita::I18n::Abstract_Store::Validator)
  end

 
end

describe Lolita::I18n::SQL_Store do 

  let(:request_klass){Lolita::I18n::SQL_Store}

  it "should create new request with params" do 
    expect{
      request = request_klass.new
      request.params = ({:a => 1})
      request.params.should eq({:a => 1})
    }.not_to raise_error
  end

  it "should return translations" do 
    r = request_klass.new
    r.params = ({})
    Lolita.i18n.should_receive(:load_translations).and_return(true)
    Lolita.i18n.stub(:yaml_backend).and_return(stub(:translations => {:en => {}}))
    Lolita::I18n::Abstract_Store::Translations.any_instance.should_receive(:normalized).once
    r.translations(:en)
  end

  it "should sort translations" do 
    r = request_klass.new
    r.params = ({})
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
    r = request_klass.new()
    r.params = ({:translation => "translation", :id => Base64.encode64("ru.key")})
    ::I18n.stub(:t).and_return("original")
    backend = double("backend")
    Lolita.i18n.stub(:backend => backend)
    backend.should_receive(:store_translations).with(:"ru", { "key" => "translation" }, :escape => false).and_return(true)
    r.update_key(r.params)
  end

  it "should have validator" do 
    r = request_klass.new()
    r.validator.should be_a_kind_of(Lolita::I18n::Abstract_Store::Validator)
  end

 
end
