require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rails'
require 'lolita'
require 'webmock/rspec'

if defined?(USE_RAILS)
  # require 'mongoid'

  # Mongoid.configure do |config|
  #   config.master = Mongo::Connection.new('127.0.0.1', 27017).db("lolita-i18n-test")
  # end

  require File.expand_path("../rails_app/config/enviroment.rb",__FILE__) 
  require "rspec/rails"
end

require File.expand_path('lib/lolita-i18n')

RSpec.configure do |config|
  config.mock_with :rspec
  config.before(:each) do
    Lolita::I18n.store.flushdb
  end
end