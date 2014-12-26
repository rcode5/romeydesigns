source 'http://rubygems.org'
ruby '2.1.5'  # commented for heroku

gem 'sinatra'
gem 'sinatra-static-assets'
gem 'sinatra-contrib'
gem 'unicorn'
gem 'haml'
gem 'sass'
gem 'chronic'
gem "data_mapper"

# krobertson's branch is still based on aws-s3 which is old and crufty
# gem "dm-paperclip-s3", :git => 'https://github.com/krobertson/dm-paperclip.git'
gem "aws-sdk"
gem "dm-paperclip-s3", :git => 'https://github.com/krzak/dm-paperclip-s3.git'
gem "rake"

group :development do
  gem 'sqlite3'
  gem 'dm-sqlite-adapter'
  gem 'tux'
end

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end

group :test, :development do
  gem 'pry'
end
group :test do
  gem "rspec"
  gem 'rspec-html-matchers'
  gem "rack-test"
  gem "mime-types"
  gem "jasmine"
  gem "jasmine-headless-webkit"
end

