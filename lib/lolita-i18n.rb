$:<<File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))
require 'redis'
require 'yajl'

module Lolita
  # === Uses Redis DB as backend
  # All translations ar stored with full key like "en.home.index.title" -> Hello world.
  # Translations whitch are translated with Google translate have prefix "g" -> "g.en.home.index.title".
  # These translations should be accepted/edited and approved then they will become as normal for general use.
  #
  # === Other stored data
  # => :unapproved_keys_<locale> - a SET containing all unapproved keys from GoogleTranslate
  #
  module I18n
    autoload :Backend, 'lolita-i18n/backend'
    autoload :GoogleTranslate, 'lolita-i18n/google_translate'

    # Loads given key/value engine as backend
    # place this method in rails initializer lolita.rb
    # === Example
    #    
    #    I18n.backend = Lolita::I18n.load Redis.new
    #
    def self.load store
      @@store=store
      @@backend=::I18n::Backend::KeyValue.new(@@store)
      @@yaml_backend=::I18n.backend
      ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Flatten)
      ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Memoize)
      ::I18n::Backend::Chain.new(Lolita::I18n.backend, @@yaml_backend)
    end

    def self.store
      @@store
    end

    def self.backend
      @@backend
    end

    def self.yaml_backend
      @@yaml_backend
    end

    # returns Array of flattened keys as "home.index.title"
    def self.flatten_keys
      @@yaml_backend.flatten_translations(nil, @@yaml_backend.send(:translations)[::I18n.default_locale] || {}, ::I18n::Backend::Flatten::SEPARATOR_ESCAPE_CHAR, false).keys
    end

  end
end

module LolitaI18nConfiguration
  def i18n
    Lolita::I18n
  end
end

Lolita.scope.extend(LolitaI18nConfiguration)

require 'lolita-i18n/module'
if Lolita.rails3?
  require 'lolita-i18n/rails'
end


Lolita.after_routes_loaded do
  if tree=Lolita::Navigation::Tree[:"left_side_navigation"]
    unless tree.branches.detect{|b| b.title=="System"}
      branch=tree.append(nil,:title=>"System")
      #mapping=Lolita::Mapping.new(:i18n_index,:singular=>:i18n,:class_name=>Object,:controller=>"lolita/i18n")
      branch.append(Object,:title=>"I18n",:url=>Proc.new{|view,branch|
        view.send(:lolita_i18n_index_path)
      }, :active=>Proc.new{|view,parent_branch,branch|
        params=view.send(:params)
        params[:controller].to_s.match(/lolita\/i18n/)
      })
    end
  end
end

