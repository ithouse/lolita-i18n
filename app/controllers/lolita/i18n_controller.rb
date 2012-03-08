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
        begin
          if Lolita::I18n::Backend.set(Base64.decode64(params[:id]),params[:translation])
            alert(::I18n.t("lolita-i18n.Successful update"))
          else
            error(::I18n.t("lolita-i18n.Error"))
          end
          render :nothing => true, :json => {error: error}
        rescue Lolita::I18n::Exceptions::MissingInterpolationArgument => e
          error(::I18n.t("lolita-i18n.Error"))
          render :nothing => true, :json => {error: e.to_s}
        end
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