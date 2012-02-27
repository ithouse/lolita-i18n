$:<<File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))
require 'redis'
require 'yajl'
require 'lolita'

module Lolita
  # === Uses Redis DB as backend
  # All translations ar stored with full key like "en.home.index.title" -> Hello world.
  # Translations whitch are translated with Google translate have prefix "g" -> "g.en.home.index.title".
  # These translations should be accepted/edited and approved then they will become as normal for general use.
  #
  # === Other stored data
  # => :unapproved_keys_<locale> - a SET containing all unapproved keys from GoogleTranslate
  #
  # In your lolita initializer add this line in setup block.
  #   config.i18n.store = {:db => 1}
  #   # or
  #   config.i18n.store = Redis.new()
  module I18n
    autoload :Backend, 'lolita-i18n/backend'
    autoload :Exceptions, 'lolita-i18n/exceptions'
    
    class Configuration

      attr_accessor :yaml_backend

      def store
        unless @store
          warn "Lolita::I18n No store specified. See Lolita::I18n"
          @store = Redis.new
        end
        @store
      end

      def store=(possible_store)
        @store = if possible_store.is_a?(Hash)
                   Redis.new(possible_store)
                 else
                   possible_store
                 end
        @store
      end

      def backend
        @backend ||= ::I18n::Backend::KeyValue.new(self.store)
      end

      # returns Array of flattened keys as "home.index.title"
      def flatten_keys
        load_translations
        self.yaml_backend.flatten_translations(nil, self.yaml_backend.send(:translations)[::I18n.default_locale] || {}, ::I18n::Backend::Flatten::SEPARATOR_ESCAPE_CHAR, false).keys
      end

      def load_translations
        # don't cache
        self.yaml_backend.load_translations
      end

      def initialize_chain
        ::I18n::Backend::Chain.new(self.backend, self.yaml_backend)
      end

      def include_modules
        ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Flatten)
        ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Pluralization)
        ::I18n::Backend::Simple.send(:include, ::I18n::Backend::Metadata)
        ::I18n::Backend::Simple.send(:include, ::I18n::Backend::InterpolationCompiler)
      end

    end
  end
end

module LolitaI18nConfiguration
  def i18n
    @i18n ||= Lolita::I18n::Configuration.new
  end
end

Lolita.scope.extend(LolitaI18nConfiguration)

Lolita.after_setup do
  Lolita.i18n.yaml_backend = ::I18n.backend
  Lolita.i18n.include_modules
  begin
    r = Redis.new
    r.ping
    ::I18n.backend = Lolita.i18n.initialize_chain
  rescue Errno::ECONNREFUSED => e
    warn "Warning: Lolita was unable to connect to Redis DB: #{e}"
  end

end

require 'lolita-i18n/module'

if Lolita.rails3?
  require 'lolita-i18n/rails'
end

Lolita.after_routes_loaded do
  if tree=Lolita::Navigation::Tree[:"left_side_navigation"]
    unless tree.branches.detect { |b| b.title=="System" }
      branch=tree.append(nil, :title=>"System")
      branch.append(Object, :title=>"I18n", :url=>Proc.new { |view, branch|
        view.send(:lolita_i18n_index_path)
      }, :active=>Proc.new { |view, parent_branch, branch|
        params=view.send(:params)
        params[:controller].to_s.match(/lolita\/i18n/)
      })
    end
  end
end
