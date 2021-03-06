# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/static_assets'
require 'sinatra/contrib'
require 'haml'
require 'data_mapper'
require 'dm-paperclip'
require 'uri'
require 'chronic'
require 'json'

LETTERS_PLUS_SPACE =  []
('a'..'z').each {|ltr| LETTERS_PLUS_SPACE << ltr}
('A'..'Z').each {|ltr| LETTERS_PLUS_SPACE << ltr}

def gen_random_string(len=8)
  numchars = LETTERS_PLUS_SPACE.length
  (0..len).map{ LETTERS_PLUS_SPACE[rand(numchars)] }.join
end

def string_to_boolean(s)
  ["true", "1", "on"].include? s.to_s.downcase
end

class String
  def truncate(len = 40, postfix = '...')
    return self if length <= len - postfix.length
    new_len = len - postfix.length - 1
    self[0..new_len] + postfix
  end
end

class Romey < Sinatra::Base
  register Sinatra::StaticAssets

  set :environment, :production
  set :logging, true
  set :root, File.dirname(__FILE__)
  APP_ROOT = root
  TIME_FORMAT = "%b %e %Y %-I:%M%p"
  DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{root}/romey.db")

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
      user = ENV['ROMEY_ADMIN_USER'] || gen_random_string
      pass = ENV['ROMEY_ADMIN_PASS'] || gen_random_string
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [user,pass]
    end

    def make_paperclip_mash(file_hash)
      mash = DataMapper::Mash.new
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
    @images = ImageResource.all.sort_by(&:id).reverse
    @baby_images = BabyImageResource.all.sort_by(&:id).reverse
    @events = EventResource.all.sort do |b,a|
      (a.starttime && b.starttime)? (a.starttime <=> b.starttime) : a.id <=> b.id
    end.select{|ev| ev.ongoing || (ev.endtime && (ev.endtime.to_time > Time.now)) }
    @links = {
      :baby => {
        :twitter => 'http://twitter.com/romeydesigns',
        :facebook => 'http://www.facebook.com/pages/Romey-Baby/349937505041234',
        :etsy => 'http://etsy.com/shop/RomeyBaby'
      },
      :grownup => {
        :twitter => 'http://twitter.com/romeydesigns',
        :facebook => 'http://www.facebook.com/RomeyDesigns',
        :etsy => 'http://etsy.com/shop/RomeyDesigns'
      }
    }

    haml :index
  end

  get '/event' do
    protected!
    haml :event, :layout => :admin_layout
  end

  get '/event/:id' do
    protected!
    @event = EventResource.get(params["id"].to_i)
    haml :event, :layout => :admin_layout
  end

  post '/event' do
    protected!
    # update timestamps
    [:starttime, :endtime].each do |thetime|
      if params["event"].has_key? thetime.to_s
        begin
          t = Chronic.parse(params["event"][thetime])
          params["event"][thetime] = t
        rescue ArgumentError
        end
      end
    end

    params["event"]["ongoing"] = (params["event"]["ongoing"] == "on") || (params["event"]["ongoing"] == "1")

    ev = EventResource.new(params["event"])
    if !ev.save
      @event = ev
      haml :event, :layout => :admin_layout
    else
      redirect '/events'
    end
  end

  post '/event/update_attr' do
    protected!
    content_type :json
    msg = nil
    if params.has_key?('id') && params.has_key?('value')
      bits = params['id'].split '_'
      event_id = bits[0]
      event_attr = bits[1]
      new_val = params['value']
      ev = EventResource.get(event_id.to_i)
      if ev
        if ev.respond_to?(event_attr)
          if ['starttime', 'endtime'].include? event_attr
            new_val = Chronic.parse(new_val)
          end
          if event_attr == 'ongoing'
            new_val = string_to_boolean(new_val)
          end
          if ev.send(event_attr) != new_val
            ev.send(event_attr + '=', new_val)
            ev.save
            if ['starttime', 'endtime'].include?(event_attr)
              t = ev.send(event_attr)
              return t && t.strftime(Romey::TIME_FORMAT)
            else
              return ev.send(event_attr).to_s
            end
          else
            msg = 'Update value is same as current.  No change'
          end
        else
          msg = "Attr #{event_attr} is not valid"
        end
      else
        msg = "Unable to find event with id #{event_id}"
      end
    else
      status 404
      msg = "Invalid POST parameters"
    end
    msg
  end

  get '/event/del/:id' do
    protected!
    ev = EventResource.get(params["id"].to_i)
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
    img = ImageResource.new(:file => params["file"])
    halt "There were issues with your upload..." unless img.save
    redirect '/uploads'
  end

  get '/admin' do
    redirect '/uploads'
  end

  get '/uploads' do
    protected!
    @title = "Uploads"
    @images = ImageResource.all.sort{|a,b| b.id <=> a.id}
    haml :uploads, :layout => :admin_layout
  end

  get '/baby/upload' do
    @title = "Upload image for baby section"
    protected!
    haml :babyupload, :layout => :admin_layout
  end

  post '/baby/upload' do
    protected!
    img = BabyImageResource.new(:file => make_paperclip_mash(params["file"]))
    halt "There were issues with your upload..." unless img.save
    redirect '/baby/uploads'
  end

  get '/baby/uploads' do
    protected!
    @title = "Baby Uploads"
    @images = BabyImageResource.all.sort{|a,b| b.id <=> a.id}
    haml :babyuploads, :layout => :admin_layout
  end

  get '/baby/pics' do
    content_type :json
    BabyImageResource.all.shuffle.to_json(:include => :url)
  end

  get '/baby/pic/del/:id' do
    protected!
    img = BabyImageResource.get(params["id"].to_i)
    if img
      img.destroy
    end
    redirect '/baby/uploads'
  end

  get '/pic/del/:id' do
    protected!
    img = ImageResource.get(params["id"].to_i)
    if img
      img.destroy
    end
    redirect '/uploads'
  end

  get '/pics' do
    content_type :json
    ImageResource.all.shuffle.to_json(:include => :url)
  end

  post '/keyword' do
    protected!
    if params["keyword"] && params["keyword"].length > 0
      kw = KeywordResource.new(:keyword => params["keyword"])
      halt 'There was a problem saving that keyword' unless kw.save
    end
    redirect '/keywords'
  end

  get '/keywords' do
    protected!
    @title = "Uploads"
    @keywords = KeywordResource.all.sort
    haml :keywords, :layout => :admin_layout
  end

  get '/keyword/del/:id' do
    protected!
    kw = KeywordResource.get(params["id"].to_i)
    if kw
      kw.destroy
    end
    redirect '/keywords'
  end

end

require File.join(File.dirname(__FILE__),"models/models.rb")

DataMapper.auto_upgrade!
