require 'rubygems'
require 'sinatra'
require 'datamapper'

set :environment, :production
set :port, 5000
disable :run, :reload

require './romey.rb'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/romey.db")

# setup static serving
use Rack::Static, :urls => [ "/images", "/stylesheets", "/javascripts"], :root => File.expand_path(File.join(Dir.pwd, 'public'))

run Romey.new
