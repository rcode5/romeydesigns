require 'sinatra'
require 'data_mapper'
require 'dm-paperclip'

class EventResource
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :length => 255
  property :description, String, :length => 1024
  property :address, String, :length => 255
  property :starttime, DateTime
  property :endtime, DateTime
  property :url, String, :length => 255
  property :ongoing, Boolean

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

DataMapper.finalize
