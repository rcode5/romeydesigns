require 'sinatra'
require 'haml'
require 'datamapper'
require 'dm-paperclip'
require 'uri'
require 'chronic'

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
    @images = []
    @images = ImageResource.all.sort{|a,b| a.id <=> b.id}
    @events = EventResource.all.sort{|a,b| (a.starttime && b.starttime)? (a.starttime <=> b.starttime) : a.id <=> b.id}.select do |ev|
      if ev.starttime
        (Time.now - (3600 * 24)).to_date < (ev.starttime).to_date
      end
    end
    haml :index
  end

  get '/event' do
    protected!
    haml :event, :layout => :admin_layout
  end

  get '/event/:id' do
    protected!
    @event = EventResource.get(params[:id])
    haml :event, :layout => :admin_layout
  end

  post '/event' do
    protected!
    # update timestamps
    [:starttime, :endtime].each do |thetime|
      if params[:event].has_key? thetime.to_s
        begin
          t = Chronic.parse(params[:event][thetime])
          params[:event][thetime] = t
        rescue ArgumentError
        end
      end
    end
    ev = EventResource.new(params[:event])
    if !ev.save
      @event = ev
      haml :event, :layout => :admin_layout
    else 
      redirect '/events'
    end
  end

  get '/event/del/:id' do
    protected!  
    ev = EventResource.get(params[:id])
    if ev
      ev.destroy
    end
    redirect '/events'
  end

  get '/events' do
    protected!
    @title = "Events"
    @events = EventResource.all.sort{|a,b| b.id <=> a.id}
    haml :events, :layout => :admin_layout
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
    @images = ImageResource.all.sort{|a,b| b.id <=> a.id}
    haml :uploads, :layout => :admin_layout
  end

  get '/pic/del/:id' do
    protected!
    img = ImageResource.get(params[:id])
    if img
      img.destroy
    end
    redirect '/uploads'
  end

  get '/pics' do
    content_type :json 
    ImageResource.all.to_json(:include => :url)
  end
end

class EventResource
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :description, String
  property :address, String
  property :starttime, DateTime
  property :endtime, DateTime
  property :url, String

  validates_presence_of :starttime

  def map_link
    "http://maps.google.com/maps?q=%s" % URI.escape(address, /[[:punct:][:space:]]/)
  end
    
  def trimmed_description
    trimmed = []
    words = description.split
    nxt = 0
    while trimmed.join.length < 100 && nxt < words.length
      trimmed << words[nxt]
      nxt += 1
    end
    result = trimmed.join ' '
    if result.length < words.join.length
      result << "..."
    end
    result
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
    :grid => { :geometry => '205x205#' }
  }
  def as_json(options = {})
    json = super
    json.merge(
    { :url => {:grid => self.file(:grid),
              :original => self.file(:original),
              :thumb => self.file(:thumb),
    }         })
  end
end

