Rails.application.routes.draw do

  namespace "lolita" do
    resources :i18n, :only=>[:index,:edit,:update,:create,:new,:destroy],:constraints=>{:id=>/.*/} do
      member do
        get :next
      end
    end
  end
end