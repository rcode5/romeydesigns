require 'sinatra'
require 'haml'
require 'datamapper'
require 'dm-paperclip'

module Paperclip
  class Tempfile < ::Tempfile
    # Replaces busted paperclip replacement of Tempfile make temp name
    def make_tmpname(basename, n)
      extension = File.extname(basename)
      sprintf("%s,%d,%d%s", File.basename(basename, extension), $$, n.to_i, extension)
    end
  end
end

class Romey < Sinatra::Base
  set :environment, :production
  set :logging, true
  set :root, Dir.pwd
  APP_ROOT = root

  DataMapper::setup(:default, "sqlite3://#{root}/romey.db")
  
  # if necessary, paperclip options can be merged in here
  #Paperclip.options.merge!()

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
    @images = ImageResource.all.sort{|a,b| b.id <=> a.id}
    haml :uploads, :layout => :admin_layout
  end

  get '/del/:id' do
    protected!
    img = ImageResource.get(params[:id])
    if img
      img.destroy
    end
    redirect '/uploads'
  end

end

class ImageResource

  include DataMapper::Resource
  include Paperclip::Resource
  
  property :id, Serial
  
  has_attached_file :file,
  :url => "/system/:attachment/:id/:style/:basename.:extension",
  :path => "#{Romey::APP_ROOT}/public/system/:attachment/:id/:style/:basename.:extension",
  :styles => { 
    :thumb => { :geometry => '100x100>' },
    :grid => { :geometry => '205x205>' }
  }
  
end
