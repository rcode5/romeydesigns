source 'http://rubygems.org'

gem 'sinatra'
gem 'sinatra-static-assets'
gem 'sinatra-contrib'
gem 'rvm-capistrano'
gem 'thin'
gem 'haml'
gem 'sass'
gem 'chronic'
gem "data_mapper"
gem "dm-paperclip"
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

