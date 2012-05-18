require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'dm-paperclip'
disable :run

root = ::File.dirname(__FILE__)
require ::File.join( root, 'romey' )

# setup static serving
use Rack::Static, :urls => [ "/images", "/stylesheets", "/javascripts"], :root => File.join(root, 'public')

Paperclip.configure do |config|
  config.root               = root # the application root to anchor relative urls (defaults to Dir.pwd)
  config.env                = ENV['RACK_ENV'] || 'development'  # server env support, defaults to ENV['RACK_ENV'] or 'development'
  config.use_dm_validations = true       # validate attachment sizes and such, defaults to false
  #config.processors_path    = 'lib/pc'   # relative path to look for processors, defaults to 'lib/paperclip_processors'
end

run Romey.new

