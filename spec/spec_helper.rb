require 'rubygems'
require 'rspec'
require 'active_record'
require 'carrierwave'
require 'carrierwave/orm/activerecord'
require 'carrierwave/processing/mini_magick'
require 'open-uri'
require 'net/http'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'carrierwave-aliyun'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: 'sqlite3',
                                        database: ':memory:')

ALIYUN_ACCESS_ID = ENV['ALIYUN_ACCESS_ID'] || ''
ALIYUN_ACCESS_KEY = ENV['ALIYUN_ACCESS_KEY'] || ''
ALIYUN_BUCKET = ENV['ALIYUN_BUCKET'] || 'carrierwave-aliyun-test'
ALIYUN_AREA = ENV['ALIYUN_AREA'] || 'cn-beijing'
ALIYUN_HOST = ENV['ALIYUN_HOST'] || 'https://carrierwave-aliyun-test.oss-cn-beijing.aliyuncs.com'

CarrierWave.root = File.expand_path('../', __dir__)

CarrierWave.configure do |config|
  config.storage = :aliyun
  config.aliyun_access_id = ALIYUN_ACCESS_ID
  config.aliyun_access_key = ALIYUN_ACCESS_KEY
  config.aliyun_bucket = ALIYUN_BUCKET
  config.aliyun_area = ALIYUN_AREA
  config.aliyun_internal = false
  config.aliyun_host = ALIYUN_HOST
  config.custom_headers = ->(uploader) {
    {}.tap do |headers|
      unless %w(jpg jpeg gif png svg).include?(uploader.file.extension.downcase)
        headers[:content_disposition] = "attachment;filename=#{uploader.file.original_filename}"
      end
    end
  }
end

def load_file(fname)
  File.open(File.join(CarrierWave.root, 'spec', fname))
end
