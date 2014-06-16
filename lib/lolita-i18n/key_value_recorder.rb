module Lolita
  module I18n
    class KeyValueRecorder < ::I18n::Backend::KeyValue
      protected

      def lookup(locale, key, scope = [], options = {})
        key   = normalize_flat_keys(locale, key, scope, options[:separator])
        if  Lolita.i18n.recording_request_path_info
          store_request_path_info(key)
        end
        value = @store["#{locale}.#{key}"]
        value = ActiveSupport::JSON.decode(value) if value
        value.is_a?(Hash) ? value.deep_symbolize_keys : value
      end

      private

      def store_request_path_info(key)
        return if @store["views.#{key}"].present? ||
          (Lolita.i18n.request_path_info && Lolita.i18n.request_path_info.match(/^\/lolita/))
        @store["views.#{key}"] = Lolita.i18n.request_path_info
      end
    end
  end
end

