require "json"
require "unicode_utils/upcase"
require_relative "../configuration"
require_relative "../store/redis_store"

module Lolita
  module I18n  
    class Redis_Configuration < Abstract_Configuration

      def new
        self.store = Lolita::I18n::Redis_Store.new() 
      end

      def store
        unless @store
          #warn "Lolita::I18n No store specified. See Lolita::I18n"
          @store = Lolita::I18n::Redis_Store.new #Create_redis_store
        end
        @store
      end

      # Set current store to new Redis connection with given Hash options or accept Redis connection itself.
      def store=(possible_store)
        @store = if possible_store.is_a?(Hash)
           Lolita::I18n::Redis_Store.new(possible_store)
         else
           possible_store
         end
        @store
      end

      def Create_redis_store
        @redis_store = Lolita::I18n::Redis_Store.new()
        return @redis_store
      end

    end
  end
end
