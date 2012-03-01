require 'rubygems'
require 'sinatra'
require 'datamapper'

disable :run, :reload

require File.join(File.dirname(__FILE__),'romey')

# setup static serving
use Rack::Static, :urls => [ "/images", "/stylesheets", "/javascripts"], :root => File.expand_path(File.join(Dir.pwd, 'public'))


run Romey.new
