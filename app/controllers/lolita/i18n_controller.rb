class Lolita::I18nController < ApplicationController
  include Lolita::ControllerAdditions
  before_action :authenticate_lolita_user!, :set_current_locale

  layout "lolita/application"

  def index
    authorization_proxy.authorize!(:read, self.resource_class)
    respond_to do |format|
      format.html do
        @translations = i18n_request.translations(@active_locale)

        if params[:sort] && params[:sort].to_s == "1"
          @translations = i18n_request.sort_translations(@translations)
        end
        render
      end
      format.xlsx do
        send_xls_file(i18n_request.xls(@active_locale), @active_locale)
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
        rescue Lolita::I18n::Exceptions::MissingInterpolationArgument => er
          render :nothing => true, :json => {error: er.to_s}
        rescue Exception => e
          render :nothing => true, :json => {error: "Key is not saved. Some error accured." }
        end
      end
    end
  end

  private

  def lolita_mapping
    Lolita.mappings[:i18n]
  end

  def next_locale
    ::I18n::available_locales.collect{|locale| locale if locale != ::I18n.default_locale}.compact.first
  end

  def set_current_locale
    @active_locale = ::I18n.available_locales.include?(params[:active_locale].to_s.to_sym) ? params[:active_locale] : nil
    @active_locale ||= next_locale
    @active_locale = @active_locale.to_sym
    @active_locale = nil if @active_locale == ::I18n.default_locale
  end

  def i18n_request
    @i18n_request ||= Lolita::I18n::Request.new(params)
  end

  def send_xls_file(translations, active_locale)
    path = Rails.root.join('tmp')
    xlsx_package = Axlsx::Package.new
    wb = xlsx_package.workbook
    wb.add_worksheet(name: "Translations") do |sheet|
      sheet.add_row ['Key', 'Url', 'Original', 'Translation']
      translations.each do |item|
        sheet.add_row [item[:key], item[:url], item[:original_translation], item[:translation]]
      end
    end
    file_name = "translations-export-#{active_locale}.xlsx"
    file_path = File.join(path, file_name)
    xlsx_package.serialize(file_path)
    send_file file_path
  end
end
