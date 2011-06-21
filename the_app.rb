require 'sinatra'

class TheApp < Sinatra::Base
  get '/' do
    'yo'
  end
end
