Rails.application.routes.draw do

  namespace "lolita" do
    resources :i18n, :only=>[:update],:constraints=>{:id=>/.*/} do
      collection do
        put 'translate_untranslated'
        get 'index'
      end
    end
  end
end