require 'rubygems'
require 'sinatra'
require 'datamapper'

disable :run, :reload

require './romey.rb'

# setup static serving
use Rack::Static, :urls => [ "/images", "/stylesheets", "/javascripts"], :root => File.expand_path(File.join(root, 'public'))


run Romey.new
