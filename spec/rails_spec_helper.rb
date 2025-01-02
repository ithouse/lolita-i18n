require 'spec_helper'

require 'mongoid'

require File.expand_path("../test_app/config/enviroment.rb",__FILE__) 
require "rspec/rails"
require 'rails-controller-testing'
require 'capybara/rails'
require 'capybara/rspec'

Capybara.server = :webrick
