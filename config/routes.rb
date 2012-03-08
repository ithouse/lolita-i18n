Rails.application.routes.draw do

  match "i18n/translate_untranslated" => "lolita/i18n#translate_untranslated"

  lolita_for :i18n, :append_to => "system", :to => "Lolita::I18n", :only => [:update, :index], :controller => "lolita/i18n", :title => "I18n"
end