require "json"
require "unicode_utils/upcase"
require_relative "../Store"
require_relative "../Translation"
require_relative "../active_record"

module Lolita
  module I18n
  
    class SQL_Store < Abstract_Store

       @store

       attr_accessor :params


      def initialize(params = nil)
         Store::SQL_Migrations.create_table
        if params == nil
         @store =  ::I18n::Backend::ActiveRecord::Translation.new()
        else
        end
      end

      def new_request(params)
        self.params = params
      end

       def [](key)
        records = ::I18n::Backend::ActiveRecord::Translation.where(:key => key)
        if records != []
          records.each do |record|
            return  record.value
          end
        else
          return nil
        end   
     end
      

     def []=(key,value)
      records = ::I18n::Backend::ActiveRecord::Translation.where(:key => key)
        if records != []
       records.each do |record|

          if record.key == key
            record.value = value
            if record.save
              return true
            else
              return false
            end
          end  
        end
      else

            record = ::I18n::Backend::ActiveRecord::Translation.new()
            record.key = key
            record.value = value
            if record.save
              return true
            else
              return false
            end
          
      end
    end

  
       def keys
        @keys = Array.new
        ::I18n::Backend::ActiveRecord::Translation.all.each do |record|
          @keys.push(record.key)
          end
        @keys
       end

       def flushdb
          ::I18n::Backend::ActiveRecord::Translation.delete_all
       end


    end


  end



end