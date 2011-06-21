require 'rubygems'
require 'sinatra'

set :environment, :production
set :port, 5000
disable :run, :reload

require './romey.rb'

run Romey.new
