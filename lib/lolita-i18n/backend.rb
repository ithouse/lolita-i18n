module Lolita
  module I18n
    # Allow to operate with I18n keys and values.
    class Backend

      class << self
        # Get translation and decode it. Set translate from and to translations.
        # Return Hash with
        # * <tt>:key</tt> - translation key
        # * <tt>:value</tt> - translation
        # * <tt>:translate_to</tt> - translation locale, like <i>en</i>
        # * <tt>:translate_from</tt> - translation key for default language
        def get(key)
          result={:key=>key}
          result[:value]=decoded_value(key)
          result[:original_value]=decoded_value(translate_from(key))
          result[:translate_to]=translate_to(key)
          result[:translate_from]=translate_from(key)
          result
        end

        # Store translation, decode and store.
        # Accept:
        # * <tt>key</tt> - translation key
        # * <tt>translation</tt> - Hash with <i>:value</i> key, that contain translation
        def set(key,translation)
          locale=translate_to(key)
          translation_key=translation_key(key)
          value=ActiveSupport::JSON.decode(translation[:value])
          ::I18n.backend.store_translations(locale,{translation_key=>value},:escape=>false)
        end

        # Return next key that can be translated.
        def next(key,from_locale)
          value=find_translation(keys.index(key)+1,keys.size-1)
          unless value
            value=find_translation(0,keys.index(key))
          end
          translate_from(value,from_locale)
        end

        def locale(key)
          translate_to(key) || ::I18n.default_locale
        end

        private

        def keys
          @keys||=::I18n.backend.store.keys.sort
          @keys
        end

        def find_translation(from,to)
          from.upto(to) do |index|
            unless ActiveSupport::JSON.decode(::I18n.backend.store[keys[index]].to_s).is_a?(Hash)
              return keys[index]
            end
          end
        end

        def decoded_value(key)
          value=::I18n.backend.store[key] || ""
          (ActiveSupport::JSON.decode(value) || "").to_s
        end

        def translate_to(key)
          key.to_s.split(".").first
        end

        def translate_from(key,locale=nil)
          key.to_s.gsub(/^\w+\./,"#{locale || ::I18n.default_locale}.")
        end

        def translation_key(key)
          key.to_s.gsub(/^\w+\./,"")
        end

      end

    end
  end
end