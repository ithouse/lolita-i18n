require 'spec_helper'


describe Store::SQL_Migrations do 
  let(:klass){Store::SQL_Migrations}

	describe '.create_table' do

   it "should not create new table if table exists" do 

      klass.create_table

    expect{klass.create_table.hould}.to raise_error

   end

    it "should create new table if there is no table" do 
      klass.delete_table
      expect{klass.create_table}.to_not raise_error
   end

  end

  describe '.delete_table' do

   it "should raise error if table doesn't exist" do 
      klass.delete_table

      expect{klass.delete_table.hould}.to raise_error
   end

    it "should delete table" do 
        klass.create_table
        expect{klass.delete_table}.to_not raise_error
   end

  end

  #  describe '.change_table' do

  #  it "should create new Store withour params" do 
  #   expect { klass.new}.to_not raise_error
  #  end

  #   it "should create new Store with params" do 
  #   expect{ klass.new(:key => "value")}.to_not raise_error
  #  end

  # end


end