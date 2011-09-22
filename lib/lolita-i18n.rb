$:<<File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))
require 'redis'
require 'yajl'

module Lolita
  module I18n
    autoload :Backend, 'lolita-i18n/backend'

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

    def self.flattened_translations
      @@yaml_backend.flatten_translations(::I18n.default_locale, merged_translations, ::I18n::Backend::Flatten::SEPARATOR_ESCAPE_CHAR, false)
    end

    def self.merged_translations
      data={}
      translations=@@yaml_backend.send(:translations)
      translations.keys.each do |lang|
        data.deep_merge!(translations[lang] || {})
      end
      {::I18n.default_locale => data}
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

