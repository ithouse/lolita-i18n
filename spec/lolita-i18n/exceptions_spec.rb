require 'spec_helper'

describe Lolita::I18n::Exceptions::MissingInterpolationArgument do 
  it "create new StandartError with custom message" do 
    error = Lolita::I18n::Exceptions::MissingInterpolationArgument.new(["arg1","arg2"])
    error.message.should eq("Translation should contain all these variables arg1, arg2")
  end
end