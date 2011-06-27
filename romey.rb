require 'sinatra'
require 'haml'
require 'datamapper'
require 'dm-paperclip'

class Romey < Sinatra::Base
  set :environment, :production
  set :logging, true
  set :root, Dir.pwd
  APP_ROOT = root

  DataMapper::setup(:default, "sqlite3://#{root}/romey.db")

  helpers do
    
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end
    
    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['jennymey', 'jonnlovesjenn']
    end

    def make_paperclip_mash(file_hash)
      mash = Mash.new
      mash['tempfile'] = file_hash[:tempfile]
      mash['filename'] = file_hash[:filename]
      mash['content_type'] = file_hash[:type]
      mash['size'] = file_hash[:tempfile].size
      mash
    end    
  end

  set :haml, :format => :html5
  get '/' do
    @title = "Romey Designs : handmade in san francisco"
    haml :index
  end
  
  get '/upload' do
    @title = "Upload image"
    protected!
    haml :upload, :layout => :admin_layout
  end

  post '/upload' do
    protected!
    img = ImageResource.new(:file => make_paperclip_mash(params[:file]))
    halt "There were issues with your upload..." unless img.save
    redirect '/uploads'
  end

  get '/uploads' do
    protected!
    @title = "Uploads"
    @images = []
    @images = ImageResource.all
    haml :uploads, :layout => :admin_layout
  end
end

class ImageResource

  include DataMapper::Resource
  include Paperclip::Resource
  
  property :id, Serial
  
  has_attached_file :file,
  :url => "/uploads/:attachment/:id/:style/:basename.:extension",
  :path => "#{Romey::APP_ROOT}/public/uploads/:attachment/:id/:style/:basename.:extension"
end
