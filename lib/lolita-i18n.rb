$:<<File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))
require 'redis'

module Lolita
  module I18n
    autoload :Backend, 'lolita-i18n/backend'

    def self.store
      @@store
    end

    def self.store=(store)
      @@store=store
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

