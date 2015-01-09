require 'spec_helper'

describe Lolita::I18n::Exceptions::MissingInterpolationArgument do 
  it "create new StandartError with custom message" do 
    error = Lolita::I18n::Exceptions::MissingInterpolationArgument.new(["arg1","arg2"])
    expect(error.message).to eq("Translation should contain all these variables arg1, arg2")
  end
end

describe Lolita::I18n::Exceptions::TranslationDoesNotMatch do 
  it "should cretae new ArgumentError with custom message" do 
    error = Lolita::I18n::Exceptions::TranslationDoesNotMatch.new("translation", "original")
    expect(error.message).to eq("Translation translation does not match original")
  end
end