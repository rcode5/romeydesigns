require 'sinatra'
require 'haml'


class Romey < Sinatra::Base
  set :haml, :format => :html5
  get '/' do
    @title = "Romey Designs : handmade in san francisco"
    haml :index
  end
end

