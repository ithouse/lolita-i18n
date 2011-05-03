Rails.application.config.after_initialize do
  I18n.backend.load_translations
end