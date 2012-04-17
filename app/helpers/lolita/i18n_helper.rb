module Lolita
  module I18nHelper
    def locale_options
      [[::I18n.t("lolita-i18n.choose-other-language"),nil]] + 
      (::I18n.available_locales - [::I18n.default_locale]).sort.map{|locale|
        [::I18n.t("#{locale}", :default => locale.to_s.upcase), locale]
      }
    end

    def translation_visible? value
      !!(!params[:show_untranslated] || value.is_a?(Array) || value.is_a?(Hash) || (params[:show_untranslated] && value.blank?))
    end

    def any_translation_visible? values
      if values.is_a?(Array)
        values.empty? || values.detect{|value| translation_visible?(value)}
      elsif values.is_a?(Hash)
        values.empty? || values.detect{|key,value| translation_visible?(value)}
      else
        translation_visible?(values)
      end
    end

    def sort_link
      sort_params = unless params[:sort]
        params.merge({:sort => 1})
      else
        params.reject{|k,v| k == "sort" || k == :sort}
      end
      url_for_sort = url_for(sort_params)
      link_to(raw("#{::I18n.t(::I18n.default_locale)} #{params[:sort] && "&uArr;"}"), url_for_sort, :id => "translation_sort_link")
    end
  end
end