require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'lolita'
require File.expand_path('lib/lolita-i18n')

RSpec.configure do |config|
  config.mock_with :rspec
  config.before(:each) do
    Lolita.i18n.store.flushdb
  end
end