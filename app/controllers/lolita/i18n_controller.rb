class Lolita::I18nController < ApplicationController
  include Lolita::ControllerAdditions
  before_filter :authenticate_lolita_user!, :set_current_locale

  layout "lolita/application"

  def index
    authorization_proxy.authorize!(:read, self.resource_class)
    @translations = i18n_request.translations(@active_locale)

    if params[:sort] && params[:sort].to_s == "1"
      @translations = @translations.sort do |pair_a,pair_b|
        value_a,value_b = pair_a[1],pair_b[1]
        if value_a[:original_translation].is_a?(Hash) || value_a[:original_translation].is_a?(Array) ||  value_b[:original_translation].is_a?(Hash) || value_b[:original_translation].is_a?(Array)
          -1
        elsif !value_a[:original_translation] || !value_b[:original_translation].to_s
          1
        else
          value_a[:original_translation].to_s <=> value_b[:original_translation].to_s
        end
      end
    end
  end

  def update
    authorization_proxy.authorize!(:update, self.resource_class)
    respond_to do |format|
      format.json do
        begin
          if saved = i18n_request.update_key 
            notice(::I18n.t("lolita-i18n.Successful update"))
          else
            error(::I18n.t("lolita-i18n.Error"))
          end
          render :nothing => true, :json => {error: !saved && ::I18n.t("lolita-i18n.Error") }
        rescue Lolita::I18n::Exceptions::MissingInterpolationArgument => e
          error(::I18n.t("lolita-i18n.Error"))
          render :nothing => true, :json => {error: e.to_s}
        rescue Exception => e
          error(::I18n.t("lolita-i18n.Error"))
          render :nothing => true, :json => {}
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

  def i18n_request
    @i18n_request ||= Lolita::I18n::Request.new(params)
  end

end