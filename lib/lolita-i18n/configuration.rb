require "json"
require "unicode_utils/upcase"

module Lolita
  module I18n
    class Abstract_Configuration

      attr_accessor :yaml_backend

        @configuration_class

      def create_configuration(store)
        puts store_conf_class_string = store+"_Configuration" 

        puts  store_conf_class = eval(store_conf_class_string)

        @configuration_class = store_conf_class.new
      end

      def create_store
        @configuration_class.new
      end

      def load_rails!
        if Lolita.rails3?
          require 'lolita-i18n/rails'
        end
      end 

      def store
        @configuration_class.store
      end

      def store=(possible_store)
        @configuration_class.store=(possible_store)
      end

      # Lazy create new KeyValue backend with current store.
      def backend
        @backend ||= ::I18n::Backend::KeyValue.new(self.store)
      end

      # Load translation from yaml.
      def load_translations
        self.yaml_backend.load_translations
      end

      # Create chain where new KeyValue backend is first and Yaml backend is second.
      def initialize_chain
        ::I18n::Backend::Chain.new(self.backend, self.yaml_backend)
      end

      # Add modules for SimpleBackend that is used for Yaml translations
      def include_modules
        ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Flatten)
        ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Pluralization)
        ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Metadata)
        ::I18n::Backend::Simple.send(:include, ::I18n::Backend::InterpolationCompiler)
      end
    
    end
  end
end
