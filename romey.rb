require 'sinatra'

class Romey < Sinatra::Base
  get '/' do
    'romey rules'
  end
end
