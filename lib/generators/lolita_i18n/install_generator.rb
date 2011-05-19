module LolitaI18n
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Lolita::Generators::FileHelper
      desc "Copy assets."

      def copy_assets
        generate("lolita_i18n:assets")
      end
     
    end
  end
end
