source "http://rubygems.org"

gem "lolita", '~>3.2.0.rc.6'
gem "hiredis", "~> 0.3.1"
gem "redis", "~> 2.2.2", :require => ["redis/connection/hiredis", "redis"]
gem "yajl-ruby", "~> 1.0.0"
gem "easy_translate", "~> 0.2.1"

group :development do
  gem "shoulda", ">= 0"
  gem "bundler", "~> 1.0.0"
  gem "jeweler", "~> 1.5.2"
  gem "rcov", ">= 0"
end

group :test do
  gem "rspec","~>2.6.0"
  gem "rspec-rails", "~>2.6.0"
  gem "webmock", "~> 1.7.6"
  # gem "mongo", "~> 1.3.0"
  # gem "mongoid", "~> 2.0.0"
  # gem "bson_ext", "~> 1.4.0"

  # For ruby 1.9.3
  # curl -OL http://rubyforge.org/frs/download.php/75414/linecache19-0.5.13.gem
  # gem install linecache19-0.5.13.gem
  # And then ruby-debug-base19x via
  # gem install --pre ruby-debug-base19x
  gem 'ruby-debug-base19x'
end
