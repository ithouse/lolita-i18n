require "json"
require "unicode_utils/upcase"
require_relative "../store"
require_relative "../translation"
require_relative "../active_record"
require 'benchmark'

module Lolita
  module I18n
    class SQL_Store < Abstract_Store
       @store
       attr_accessor :params


      def initialize(params = nil)
        Store::SQL_Migrations.create_table
        if params == nil
          @store =  ::I18n::Backend::ActiveRecord::Translation.new()
        end
      end

      def new_request(params)
        self.params = params
      end



      def [](t_key)
        if( record = ::I18n::Backend::ActiveRecord::Translation.where(:t_key => t_key).first)
          return  record.value
        else
          return nil
        end   
      end



      def []=(t_key,value)
        if(record = ::I18n::Backend::ActiveRecord::Translation.where(:t_key => t_key).first)
          if record.t_key == t_key
            record.value = value
            if record.save
              return true
            else
              return false
            end
          end  
        else
          record = ::I18n::Backend::ActiveRecord::Translation.new()
          record.t_key = t_key
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
          @keys.push(record.t_key)
        end
        @keys
      end


      def flushdb
        ::I18n::Backend::ActiveRecord::Translation.delete_all
      end


    end
  end
end