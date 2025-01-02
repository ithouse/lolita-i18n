require_relative 'boot'
require "action_controller/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module Test
  class Application < Rails::Application
    config.root                       = File.expand_path("#{File.dirname(__FILE__)}/..")
    config.logger                     = Logger.new(File.join(config.root,"log","development.log"))
    config.active_support.deprecation = :log
    config.i18n.default_locale        = :en
    config.assets.enabled = true
    #config.autoload_paths=File.expand_path("../#{File.dirname(__FILE__)}")
  end
end
