require 'spec_helper'
share_examples_for "a store" do
 describe '#new' do

   it "should create new Store withour params" do 
    expect { klass.new}.to_not raise_error
   end

    it "should create new Store with params" do 
    expect{ klass.new(:key => "value")}.to_not raise_error
   end

  end
   describe '#[](key)' do
    it "should allow to send key" do 
     expect {store['test_key']}.to_not raise_error
   end

   it "should get value fom key" do 
     store['test_key'].should == 'test_value' 
   end

    it "should receive nil for undefined key" do 
    store['undefined_key'].should == nil
  end

 end


  describe '#[]=(key,value)' do
    it "should allow to set value for key" do 
     expect {store['test_key']='new_value'}.to_not raise_error
   end
    it "should set new value for key" do 
     store['test_key']='new_value'
     store['test_key'].should == 'new_value'
   end

 end


  describe '#keys' do
    it "should allow to request all keys" do 
     expect {store.keys}.to_not raise_error
   end
    it "should return keys" do 
     store.keys.should include("test_key","test_key2")
   end

end



  end

