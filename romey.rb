require 'sinatra'
require 'haml'

class Romey < Sinatra::Base
  get '/' do
    @title = "Romey Rocks right now #{Time.now}"
    haml :index
  end
end
