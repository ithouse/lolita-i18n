Rails.application.routes.draw do
  lolita_for :i18n, :append_to => "system", :to => "Lolita::I18n", :only => [:update, :index], :controller => "lolita/i18n", :title => "I18n"
end