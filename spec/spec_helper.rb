require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'
require 'mocha'
require 'data_mapper'
require 'dm-paperclip'
require 'rspec-html-matchers'

require File.join(File.dirname(__FILE__), '..', 'romey.rb')

set :environment, :test

ENV['ROMEY_ADMIN_USER'] = 'whatever'
ENV['ROMEY_ADMIN_PASS'] = 'whatever'

RSpec.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
end
