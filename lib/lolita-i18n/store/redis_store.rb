require "json"
require "unicode_utils/upcase"
require_relative "../store"
require_relative "../translation"
require 'profile'

module Lolita
  module I18n
    class Redis_Store < Abstract_Store

      @store
      attr_accessor :params

      def initialize(possible_store = "nothing")
        if possible_store == "nothing"
          @store =  Redis.new
        else
          @store = Redis.new(possible_store)
          self.params = possible_store
        end
      end

      def [](key)
        @store[key]
      end

      def []=(key,value)
        @store[key] = value
      end
  
      def keys
        @store.keys
      end

      def del(key)
        raise 'This method should be overriden and delete value, for givven key'
      end

      def flushdb
        @store.flushdb
      end

    end
  end
end