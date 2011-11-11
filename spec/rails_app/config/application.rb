require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"

#require File.expand_path("../../../../lib/lolita-i18n",__FILE__)
#require 'i18n'

module Test
  class Application < Rails::Application
    config.root=File.expand_path("#{File.dirname(__FILE__)}/..")
    config.logger=Logger.new(File.join(config.root,"log","development.log"))
    config.active_support.deprecation=:log
    config.i18n.default_locale = :en
    
    #config.autoload_paths=File.expand_path("../#{File.dirname(__FILE__)}")
  end
end
