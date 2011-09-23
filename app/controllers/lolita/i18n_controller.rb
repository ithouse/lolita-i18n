class Lolita::I18nController < ApplicationController
  include Lolita::Controllers::UserHelpers
  before_filter :authenticate_lolita_user!

  layout "lolita/application"

  def index
    @translation_keys=Lolita::I18n.flattened_translations.keys
    @active_locale = (params[:active_locale] || next_locale).to_sym
  end

  def update
    respond_to do |format|
      format.json do
        render :nothing => true, :json => {error: !Lolita::I18n::Backend.set(params[:id],params[:translation])}
      end
    end
  end

  private

  def next_locale
    ::I18n::available_locales.collect{|locale| locale if locale != ::I18n.default_locale}.compact.first
  end
end