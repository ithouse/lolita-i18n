class Lolita::I18nController < ApplicationController
  include Lolita::ControllerAdditions
  before_filter :authenticate_lolita_user!, :set_current_locale

  layout "lolita/application"

  def index
    authorize!(:read, self.resource_class)
    @translation_keys=Lolita.i18n.flatten_keys
  end

  def update
    authorize!(:update, self.resource_class)
    respond_to do |format|
      format.json do
        render :nothing => true, :json => {error: !Lolita::I18n::Backend.set(params[:id],params[:translation])}
      end
    end
  end

  def translate_untranslated
    authorize!(:update,self.resource_class)
    respond_to do |format|
      format.json do
        google_translate = Lolita::I18n::GoogleTranslate.new @active_locale
        google_translate.run
        render :nothing => true, :status => 200, :json => {errors: google_translate.errors, :translated => google_translate.untranslated}
      end
    end    
  end

  private
  
  def lolita_mapping
    params[:action] == "translate_untranslated" ? Lolita.mappings[:i18n] : super 
  end

  def next_locale
    ::I18n::available_locales.collect{|locale| locale if locale != ::I18n.default_locale}.compact.first
  end

  def set_current_locale
    @active_locale = (params[:active_locale] || next_locale).to_sym
  end

end