require 'generators/helpers/file_helper'
module LolitaI18n
  module Generators
    class AssetsGenerator < Rails::Generators::Base
      include Lolita::Generators::FileHelper
      desc "Copy all from public directory to project public directory."
      def copy_all
        root=File.expand_path("../../../../",__FILE__)
        copy_dir("public",:root=>root)
      end      
    end
  end
end