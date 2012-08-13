require 'spec_helper'


describe Lolita::I18n::Version do 
  it "should return current version of gem" do 
    Lolita::I18n::Version.to_s.should match(/\d+\.\d+\.\d+/)
  end
end