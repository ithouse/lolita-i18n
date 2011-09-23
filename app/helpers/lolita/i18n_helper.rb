module Lolita
  module I18nHelper
    def locale_options
      @@locale_options ||= ::I18n::available_locales.collect{|locale| 
        [::I18n.t(locale, :default => locale), locale] unless [::I18n.default_locale,@active_locale].include?(locale)
      }.compact.insert(0,[::I18n.t("lolita-i18n.choose-other-language", :default => "Choose other language"),""])
    end
  end
end