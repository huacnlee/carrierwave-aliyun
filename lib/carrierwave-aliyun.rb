require 'carrierwave/storage/aliyun'
require 'carrierwave/storage/aliyun_file'
require 'carrierwave/aliyun/bucket'
require 'carrierwave/aliyun/version'
require 'carrierwave/aliyun/configuration'

CarrierWave::Uploader::Base.send(:include, CarrierWave::Aliyun::Configuration)