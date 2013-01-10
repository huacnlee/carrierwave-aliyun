require "carrierwave/storage/aliyun"
require 'carrierwave/processing/mime_types'
require "carrierwave/aliyun/configuration"
CarrierWave.configure do |config|
  config.storage_engines.merge!({:aliyun => "CarrierWave::Storage::Aliyun"})
end
CarrierWave::Uploader::Base.send(:include, CarrierWave::Aliyun::Configuration)
CarrierWave::Uploader::Base.send(:include, CarrierWave::MimeTypes)
CarrierWave::Uploader::Base.send(:process, :set_content_type)