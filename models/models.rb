require 'sinatra'
require 'datamapper'
require 'dm-paperclip'

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
    json.merge({ :url => {:grid => self.file(:grid),
        :original => self.file(:original),
        :thumb => self.file(:thumb) }
               })
  end
end

class BabyImageResource

  include DataMapper::Resource
  include Paperclip::Resource
  
  property :id, Serial
  
  has_attached_file :file,
  :url => "/system/baby/:attachment/:id/:style/:basename.:extension",
  :path => "#{Romey::APP_ROOT}/public/system/baby/:attachment/:id/:style/:basename.:extension",
  :styles => { 
    :thumb => { :geometry => '100x100>' },
    :grid => { :geometry => '205x205#' }
  }
  def as_json(options = {})
    json = super
    json.merge({ :url => {:grid => self.file(:grid),
        :original => self.file(:original),
        :thumb => self.file(:thumb) }
               })
  end
end

class EventResource
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :length => 255
  property :description, String, :length => 1024
  property :address, String, :length => 255
  property :starttime, DateTime
  property :endtime, DateTime
  property :url, String, :length => 255

  validates_presence_of :starttime
  validates_presence_of :title

  def map_link
    if address.present?
      "http://maps.google.com/maps?q=%s" % URI.escape(address, /[[:punct:][:space:]]/)
    end
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

class Object
  def empty?
    (self == nil) || (self.respond_to?(:length) && self.length == 0)
  end
  def present?
    !empty?
  end
end

    
DataMapper.finalize
