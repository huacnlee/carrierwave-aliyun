require 'carrierwave/storage/aliyun'
require 'carrierwave/aliyun/configuration'

CarrierWave.configure do |config|
  config.storage_engines.merge!({ aliyun: 'CarrierWave::Storage::Aliyun' })
end
CarrierWave::Uploader::Base.send(:include, CarrierWave::Aliyun::Configuration)

if CarrierWave::VERSION <= '0.11.0'
  require 'carrierwave/processing/mime_types'
  CarrierWave::Uploader::Base.send(:include, CarrierWave::MimeTypes)
  CarrierWave::Uploader::Base.send(:process, :set_content_type)
end
