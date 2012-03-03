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

class Object
  def empty?
    (self == nil) || (self.respond_to?(:length) && self.length == 0)
  end
  def present?
    !empty?
  end
end

    
DataMapper.finalize
