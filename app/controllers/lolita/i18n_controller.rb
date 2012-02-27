class Lolita::I18nController < ApplicationController
  include Lolita::ControllerAdditions
  before_filter :authenticate_lolita_user!, :set_current_locale

  layout "lolita/application"

  def index
    @translation_keys=Lolita.i18n.flatten_keys
  end

  def update
    respond_to do |format|
      format.json do
        error = false
        begin
          Lolita::I18n::Backend.set(params[:id],params[:translation])
        rescue Lolita::I18n::Exceptions::MissingInterpolationArgument => e
          error = e.to_s
        end
        render :nothing => true, :json => {error: error}
      end
    end
  end

  private
  
  def is_lolita_resource?
    true
  end

  def next_locale
    ::I18n::available_locales.collect{|locale| locale if locale != ::I18n.default_locale}.compact.first
  end

  def set_current_locale
    @active_locale = (params[:active_locale] || next_locale).to_sym
  end

end