module Lolita
  module I18nHelper
    def locale_options
      [[::I18n.t("lolita-i18n.choose-other-language"),nil]] + 
      (::I18n.available_locales - [::I18n.default_locale]).sort.map{|locale|
        [::I18n.t("#{locale}", :default => locale.to_s.upcase), locale]
      }
    end

    def translation active_locale, key, original_key, translation, original, url = nil
      %Q{
        <td style="width:450px", data-key="#{active_locale}.#{original_key}" data-locale="#{active_locale}">
          <p>
            #{text_area_tag "#{active_locale}.#{key}", translation}
          </p>
        </td>
        <td style="width:90%" data-key="#{::I18n.default_locale}.#{original_key}" data-locale="#{::I18n.default_locale}">
          <p>
            #{text_area_tag "#{::I18n.default_locale}.#{key}", original}
          </p>
          #{!key.blank? ? "<span class='hint'>#{key}</span>" : ''}
          #{url.present? ? "<span class='hint'>#{url}</span>" : ''}
        </td>
      }
    end

    def is_untranslated? value
      if value.is_a?(Array) || value.is_a?(Hash)
        true
      else
        value.blank?
      end
    end

    def translation_visible? value, url
      result = true
      if params[:show_untranslated]
        result = result && is_untranslated?(value)
      end
      if params[:show_with_url]
        result = result && url.present?
      end
      result
    end

    def any_translation_visible? values, url
      if values.is_a?(Array)
        values.empty? || values.detect{|value| translation_visible?(value, url)}
      elsif values.is_a?(Hash)
        values.empty? || values.detect{|key,value| translation_visible?(value, url)}
      else
        translation_visible?(values, url)
      end
    end

    def sort_link
      sort_params = unless params[:sort]
        params.merge({:sort => 1})
      else
        params.reject{|k,v| k == "sort" || k == :sort}
      end
      url_for_sort = url_for(sort_params.permit!)
      link_to(raw("#{::I18n.t(::I18n.default_locale)} #{params[:sort] && "&uArr;"}"), url_for_sort, :id => "translation_sort_link")
    end
  end
end
