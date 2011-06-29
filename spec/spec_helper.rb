require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'
require 'mocha'
require 'datamapper'
require 'dm-paperclip'
require 'rspec_hpricot_matchers'

require File.join(File.dirname(__FILE__), '..', 'romey.rb')

set :environment, :test

RSpec.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
  config.include(RspecHpricotMatchers)
end
