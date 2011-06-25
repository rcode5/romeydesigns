require File.join(File.dirname(__FILE__), '..', 'romey.rb')

require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'
require 'datamapper'

set :environment, :test

RSpec.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
end
