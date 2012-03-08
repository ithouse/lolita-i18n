module Lolita
  module I18nHelper
    def locale_options
      (::I18n::available_locales).collect{|locale| 
        [::I18n.t(locale, :default => locale), locale] unless [::I18n.default_locale,@active_locale].include?(locale)
      }.compact.insert(0,[::I18n.t("lolita-i18n.choose-other-language", :default => ::I18n.t("lolita-i18n.choose-other-language", :locale => "en")),""])
    end

    def show_translation key
      ::I18n.t(key, :locale => @active_locale, :default => '')
    end

    def is_untranslated key
      ::I18n.t(key, :locale => @active_locale, :default => "").blank?
    end
  end
end