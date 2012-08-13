require 'spec_helper'



describe Lolita::I18n::SQL_Store do 
  let(:klass){Lolita::I18n::SQL_Store}
  let(:store){klass.new} 

before(:all) do
    sql_config = Lolita::I18n::SQL_Configuration.new
    store = Lolita::I18n::SQL_Store.new
    store['test_key']='test_value'
    store['test_key2']='test_value2'
  end

 it_should_behave_like "a store"

end