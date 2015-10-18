require 'data_mapper'
class KeywordResource
  include DataMapper::Resource
  property :id, Serial
  property :keyword, String
end
DataMapper.finalize
