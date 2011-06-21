require 'sinatra'

class TheApp < Sinatra::Base
  get '/' do
    'romey rules'
  end
end
