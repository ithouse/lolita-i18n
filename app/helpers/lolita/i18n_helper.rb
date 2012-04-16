module Lolita
  module I18nHelper
    def locale_options
      [[::I18n.t("lolita-i18n.choose-other-language"),nil]] + 
      (::I18n.available_locales - [::I18n.default_locale]).map{|locale|
        [::I18n.t("#{locale}", :default => locale.to_s.upcase), locale]
      }
    end

    def show_translation key
      ::I18n.t(key, :locale => @active_locale, :default => '')
    end

    def is_untranslated key
      ::I18n.t(key, :locale => @active_locale, :default => "").blank?
    end

    def sort_link
      sort_params = unless params[:sort]
        params.merge({:sort => 1})
      else
        params.reject{|k,v| k == "sort"}
      end
      url_for_sort = url_for(sort_params)
      link_to(raw("#{::I18n.t(::I18n.default_locale)} #{params[:sort] && "&uArr;"}"), url_for_sort)
    end
  end
end