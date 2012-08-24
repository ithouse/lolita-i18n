$:<<File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))

require 'redis'
require 'yajl'
require 'lolita'
require 'lolita-i18n'


module Lolita
    # All translations ar stored with full key like "en.home.index.title" -> Hello world.

  # In your lolita initializer add this line in setup block.
  #   config.i18n.create_configuration('SQL')
  #   # or
  #   config.i18n.create_configuration('Redis')
  module I18n
    autoload :SQL_Configuration, 'lolita-i18n/configuration/sql_configuration'
    autoload :Redis_Configuration, 'lolita-i18n/configuration/redis_configuration'
    autoload :ActiveRecord, 'lolita-i18n/active_record'
    autoload :Exceptions, 'lolita-i18n/exceptions'
    autoload :Abstract_Configuration, 'lolita-i18n/configuration'

  end
end

module LolitaI18nConfiguration
  def i18n
      @i18n ||= Lolita::I18n::Abstract_Configuration.new
  end
end

Lolita.configuration.extend(LolitaI18nConfiguration)

Lolita.after_setup do
  Lolita.i18n.yaml_backend = ::I18n.backend
  Lolita.i18n.include_modules
  begin
    r = Lolita.i18n.create_store
  #  r.ping
    ::I18n.backend = Lolita.i18n.initialize_chain
  rescue Errno::ECONNREFUSED => e
    warn "Warning: Lolita was unable to connect to Redis DB: #{e}"
  end
  true
end

Lolita.i18n.load_rails!

require 'lolita-i18n/module'
require 'lolita-i18n/version'

