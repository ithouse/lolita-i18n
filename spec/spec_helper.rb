require 'rubygems'
require 'bundler'

# run simplecov only wehen all tests are executed
if ARGV.empty? || ARGV.include?("spec")
  require 'simplecov'
  SimpleCov.start 'rails'
end

REQUIRE_RAILS = true # turn of to run lolita-i18n tests fast

begin
  Bundler.setup(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

if REQUIRE_RAILS
  require 'rails'
  require 'rails_spec_helper'
end
require File.expand_path('lib/lolita-i18n')

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.mock_with :rspec
  config.before(:each, :redis) do
    Lolita.i18n.store.flushdb
  end

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!

  [:controller, :view, :request].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, :type => type
    config.include ::Rails::Controller::Testing::TemplateAssertions, :type => type
    config.include ::Rails::Controller::Testing::Integration, :type => type
  end
end
