require 'sinatra'
require 'haml'


class Romey < Sinatra::Base
  set :haml, :format => :html5
  get '/' do
    @title = "Romey Rocks right now #{Time.now}"
    haml :index
  end
end
