source 'http://rubygems.org'
ruby '1.9.3'

gem 'sinatra'
gem 'sinatra-static-assets'
gem 'sinatra-contrib'
gem 'rvm-capistrano'
gem 'thin'
gem 'haml'
gem 'sass'
gem 'chronic'
gem "data_mapper"
# krobertson's needs a few patches for heroku/s3 tiein
gem "dm-paperclip", :git => 'https://github.com/krobertson/dm-paperclip.git'
gem 'aws-s3'
gem "rake"
gem 'heroku'

group :development do
  gem 'sqlite3'
  gem 'dm-sqlite-adapter'
end

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end

group :test do
  gem "rspec"
  gem "mocha"
  gem 'hpricot'
  gem 'rspec_hpricot_matchers'
  gem "rack-test"
  gem "mime-types"
  gem "jasmine"
  gem "jasmine-headless-webkit"
end

