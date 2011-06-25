require 'rubygems'
require 'sinatra'

set :environment, :production
set :port, 5000
disable :run, :reload

require './romey.rb'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/romey.db")

run Romey.new
