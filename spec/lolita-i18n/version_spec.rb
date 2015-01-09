require 'spec_helper'


describe Lolita::I18n::Version do 
  it "should return current version of gem" do 
    expect(Lolita::I18n::Version.to_s).to match(/\d+\.\d+\.\d+/)
  end
end