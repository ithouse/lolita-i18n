$:<<File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))
require 'redis'
require 'yajl'
require 'lolita'


module Lolita
  # === Uses Redis DB as backend
  # All translations ar stored with full key like "en.home.index.title" -> Hello world.

  # In your lolita initializer add this line in setup block.
  #   config.i18n.store = {redis_confguration_goes_here}
  #   # or
  #   config.i18n.store = Redis.new() # default store 
  module I18n
    autoload :Request, 'lolita-i18n/request'
    autoload :Exceptions, 'lolita-i18n/exceptions'
    autoload :Configuration, 'lolita-i18n/configuration'
  end
end

module LolitaI18nConfiguration
  def i18n
    @i18n ||= Lolita::I18n::Configuration.new
  end
end

Lolita.configuration.extend(LolitaI18nConfiguration)

Lolita.after_setup do
  Lolita.i18n.init
end

Lolita.i18n.load_rails!

require 'lolita-i18n/module'
require 'lolita-i18n/version'

