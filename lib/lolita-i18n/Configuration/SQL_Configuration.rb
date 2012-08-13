require "json"
require "unicode_utils/upcase"
require_relative "../Configuration"
require_relative "../Store/SQL_Store"
require_relative "../Store/SQL_Migrations"

module Lolita
  module I18n

    class SQL_Configuration < Abstract_Configuration
      @store

      def new
        #Store::SQL_Migrations.create_table
        self.store = Lolita::I18n::SQL_Store.new()
      end

      def store
        unless @store
          #warn "Lolita::I18n No SQL store specified. See Lolita::I18n"
          @store = Lolita::I18n::SQL_Store.new 
        end
        @store
      end

      # Set current store to new Redis connection with given Hash options or accept Redis connection itself.
      def store=(possible_store)
        @store = if possible_store.is_a?(Hash)
           Lolita::I18n::SQL_Store.new(possible_store)
         else
           possible_store
         end
        @store
      end

      def Create_sql_store
        @sql_store = Lolita::I18n::SQL_Store.new()
      end


    end



  end



end
