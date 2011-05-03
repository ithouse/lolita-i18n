require 'rubygems'
if USE_RAILS
  require 'mongoid'

  Mongoid.configure do |config|
    config.master = Mongo::Connection.new('127.0.0.1', 27017).db("lolita-i18n-test")
  end

  require File.expand_path("../rails_app/config/enviroment.rb",__FILE__) 
  require "rspec/rails"
end
require File.expand_path('lib/lolita-i18n')