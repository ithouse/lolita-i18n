require 'easy_translate'

module Lolita
  module I18n
    # Translates untranslated strings using google translate API
    class GoogleTranslate
      attr_reader :untranslated, :errors
      def initialize locale
        @locale = locale
        @untranslated = 0
        @errors = []
      end

      def run
        unless untranslated_translations.empty?
          @untranslated = untranslated_translations.count
          untranslated_translations.each_slice(10).to_a.each do |batch|
            begin
              EasyTranslate.translate(batch.map(&:last), :to => @locale).each_with_index do |result,index|
                unless result.blank?
                  key = batch[index].first
                  add_translation key, result
                  add_to_unapproved key
                end
              end
            rescue EasyTranslate::EasyTranslateException => e
              @errors << e.to_s
            rescue Exception => e
              puts "#{e.to_s}\n\n#{$@.join("\n")}"
              @errors << e.to_s
              break
            end
          end
        end
      end

      def untranslated_translations
        unless @untranslated_translations
          @untranslated_translations = []
          Lolita.i18n.flatten_keys.each do |key|
            unless unapproved_keys.include?(key)
              if !::I18n.t(key, :locale => ::I18n.default_locale, :default => '').blank? && ::I18n.t(key, :locale => @locale, :default => '').blank? && Lolita::I18n::GoogleTranslate.get_translation(@locale,key).blank?
                value = ::I18n.t(key, :locale => ::I18n.default_locale, :default => '').to_s
                @untranslated_translations << [key,value] unless value.blank?
              end
            end
          end
        end
        @untranslated_translations
      end
      
      def self.get_translation locale, key
        Lolita.i18n.store.get :"#{locale}.g.#{key}"
      end

      def self.del_translation locale, key
        Lolita.i18n.store.del :"#{locale}.g.#{key}"
      end

      private

      def unapproved_keys
        @@unapproved_keys ||= Lolita.i18n.store.smembers(:"unapproved_keys_#{@locale}").map(&:to_sym)
      end

      def add_translation key, value
        Lolita.i18n.store.set :"#{@locale}.g.#{key}", value
      end

      def add_to_unapproved key
        Lolita.i18n.store.sadd(:"unapproved_keys_#{@locale}",key)
      end

    end
  end
end