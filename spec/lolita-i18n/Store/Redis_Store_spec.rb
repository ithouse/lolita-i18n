require 'spec_helper'



describe Lolita::I18n::Redis_Store do 
  let(:klass){Lolita::I18n::Redis_Store}
  let(:store){klass.new} 


  before(:all) do
    redis_config = Lolita::I18n::Redis_Configuration.new
    store = redis_config.store
    store['test_key']='test_value'
    store['test_key2']='test_value2'
  end

 it_should_behave_like "a store"

end




