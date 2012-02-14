require "carrierwave/storage/aliyun"
require "carrierwave/aliyun/configuration"
CarrierWave.configure do |config|
  config.storage_engines.merge!({:aliyun => "CarrierWave::Storage::Aliyun"})
end
CarrierWave::Uploader::Base.send(:include, CarrierWave::Aliyun::Configuration)