# coding: utf-8

USE_RAILS=true unless defined?(USE_RAILS)
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lolita::I18n::GoogleTranslate do
  let(:google_translate){
    stub_request(:post, "http://ajax.googleapis.com/ajax/services/language/translate").
    with(:body => "v=2.0&format=text&q=true&langpair=%7Clv&q=true&langpair=%7Clv&q=Posts&langpair=%7Clv&q=Posts%20description&langpair=%7Clv&q=Comments&langpair=%7Clv&q=Comment%20description&langpair=%7Clv&q=Footer%20text&langpair=%7Clv",
    :headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => '{"responseData": [{"responseData":{"translatedText":"patiess","detectedSourceLanguage":"en"},"responseDetails":null,"responseStatus":200},{"responseData":{"translatedText":"patiess","detectedSourceLanguage":"en"},"responseDetails":null,"responseStatus":200},{"responseData":{"translatedText":"Atbildes","detectedSourceLanguage":"en"},"responseDetails":null,"responseStatus":200},{"responseData":{"translatedText":"Atbildes apraksts","detectedSourceLanguage":"en"},"responseDetails":null,"responseStatus":200},{"responseData":{"translatedText":"Komentāri","detectedSourceLanguage":"en"},"responseDetails":null,"responseStatus":200},{"responseData":{"translatedText":"Cik apraksts","detectedSourceLanguage":"fr"},"responseDetails":null,"responseStatus":200},{"responseData":{"translatedText":"Kājenes tekstu","detectedSourceLanguage":"en"},"responseDetails":null,"responseStatus":200}], "responseDetails": null, "responseStatus": 200}', :headers => {})

    gt = Lolita::I18n::GoogleTranslate.new(:lv)
    gt.run
    gt
  }

  it "should store google translation" do
    google_translate.untranslated_translations.size.should == 7
    google_translate.untranslated.should == 7
    google_translate.errors.should be_empty
    Lolita::I18n::GoogleTranslate.get_translation(:lv, :'posts.Description').should == "Atbildes apraksts"
  end

  it "should delete google translation" do
    google_translate
    Lolita::I18n::GoogleTranslate.get_translation(:lv, :'posts.Description').should == "Atbildes apraksts"
    Lolita::I18n::GoogleTranslate.del_translation(:lv, :'posts.Description')
    Lolita::I18n::GoogleTranslate.get_translation(:lv, :'posts.Description').should be_nil
  end
end