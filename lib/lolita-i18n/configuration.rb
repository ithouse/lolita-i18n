module Lolita
  module I18n
    class Configuration

      attr_accessor :yaml_backend,
        :request_path_info
      attr_reader :recording_request_path_info

      def load_rails!
        if Lolita.rails?
          require 'lolita-i18n/rails'
        end
      end
      # Rerturn existing store or create new Redis connection without any arguments.
      def store
        unless @store
          warn "Lolita::I18n No store specified. See Lolita::I18n"
          @store = Redis.new
        end
        @store
      end

      # Set current store to new Redis connection with given Hash options or accept Redis connection itself.
      def store=(possible_store)
        @store = if possible_store.is_a?(Hash)
           Redis.new(possible_store)
         else
           possible_store
         end
        @store
      end

      # Lazy create new KeyValue backend with current store.
      def backend
        @backend ||= KeyValueRecorder.new(self.store)
        #@backend ||= ::I18n::Backend::KeyValue.new(self.store)
      end

      # Load translation from yaml.
      def load_translations
        @yaml_backend.load_translations
      end

      # Create chain where new KeyValue backend is first and Yaml backend is second.
      def initialize_chain
        ::I18n::Backend::Chain.new(self.backend, self.yaml_backend)
      end

      def init
        unless @initialized
          include_modules
          set_yaml_backend
          @initialized = true
          connect
        end
      end

      def connect
        unless @connected
          reconnect
        end
      end

      def reconnect
        unless @initialized
          init
        else
          disconnect
          @connected = begin
            store.client.reconnect
            store.ping
            ::I18n.backend = initialize_chain
            true
          rescue Errno::ECONNREFUSED => e
            warn "Warning: Lolita was unable to connect to Redis DB: #{e}"
            false
          end
        end
      end

      def disconnect
        if @connected
          store.client.disconnect
          @connected = false
        end
      end

      def set_yaml_backend
        @yaml_backend ||= ::I18n.backend
      end

      # Add modules for SimpleBackend that is used for Yaml translations
      def include_modules
        ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Flatten)
        ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Pluralization)
        ::I18n::Backend::Simple.send(:include, ::I18n::Backend::InterpolationCompiler)
      end

      def set_recording_request_path_info
        @recording_request_path_info = true
      end
    end

  end
end
