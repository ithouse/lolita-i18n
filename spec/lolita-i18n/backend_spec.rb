USE_RAILS=true unless defined?(USE_RAILS)
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Lolita::I18n::Backend do

  it "should have fallback to default I18n store" do
    I18n.t("Page title").should == "Page title"
  end

  it "should set translation into DB" do
    ::I18n.t("test-key", :locale => :en, :default => '').should == ''
    Lolita::I18n::Backend.set("en.test-key","Hello")
    ::I18n.t("test-key", :locale => :en, :default => '').should == 'Hello'
  end

  it "should delete key from DB if empty value given" do
    Lolita::I18n::Backend.set("en.test-key","Hello")
    Lolita::I18n::Backend.get("en.test-key")[:value].should == "Hello"
    Lolita::I18n::Backend.set("en.test-key","")
    Lolita.i18n.store.get("en.test-key").should be_nil
  end

  it "should get translation into DB" do
    Lolita::I18n::Backend.get("en.test-key")[:value].should == ''
    Lolita::I18n::Backend.set("en.test-key","Hello")
    Lolita::I18n::Backend.get("en.test-key")[:value].should == "Hello"
  end

  it "should raise Lolita::I18n::Exceptions::MissingInterpolationArgument" do
    lambda {Lolita::I18n::Backend.set("lv.copyright","Autortiesibas 2010-2012")}.should raise_error(Lolita::I18n::Exceptions::MissingInterpolationArgument)
    lambda {Lolita::I18n::Backend.set("lv.copyright","Autortiesibas %{year_from}-%{year_till}")}.should_not raise_error(Lolita::I18n::Exceptions::MissingInterpolationArgument)
  end
end