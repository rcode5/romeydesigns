require 'data_mapper'
require 'dm-paperclip'

class BabyImageResource

  include DataMapper::Resource
  include Paperclip::Resource

  property :id, Serial
  has_attached_file :file,
                    storage: :s3,
                    path: "baby_images/:style/:filename",
                    s3_credentials: {
                      access_key_id: ENV['S3_ACCESS_KEY'],
                      secret_access_key: ENV['S3_SECRET'],
                      bucket: ENV['S3_BUCKET'] || 'romeydev'
                    },
                    styles: {
                      thumb: { geometry: '100x100>' },
                      grid: { geometry: '205x205#' }
                    }
  def as_json(options = {})
    json = super
    json.merge({ url: {grid: self.file(:grid),
                       original: self.file(:original),
                       thumb: self.file(:thumb) }
               })
  end
end

DataMapper.finalize
