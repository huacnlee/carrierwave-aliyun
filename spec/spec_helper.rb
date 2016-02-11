require 'rubygems'
require 'rspec'
require 'rails'
require 'active_record'
require "carrierwave"
require 'carrierwave/orm/activerecord'
require 'carrierwave/processing/mini_magick'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require "carrierwave-aliyun"


module Rails
  class <<self
    def root
      [File.expand_path(__FILE__).split('/')[0..-3].join('/'),"spec"].join("/")
    end
  end
end

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.raise_in_transactional_callbacks = true

# 测试的时候需要修改这个地方
ALIYUN_ACCESS_ID = "1OpWEtPTjIDv5u8q"
ALIYUN_ACCESS_KEY = 'cz12XgPfEVy8Xe9F9UJJHmVdHBJ9bi'
ALIYUN_BUCKET = "carrierwave-aliyun-test"
ALIYUN_AREA = "cn-beijing"

CarrierWave.configure do |config|
  config.storage = :aliyun
  config.aliyun_access_id = ALIYUN_ACCESS_ID
  config.aliyun_access_key = ALIYUN_ACCESS_KEY
  config.aliyun_bucket = ALIYUN_BUCKET
  config.aliyun_area = ALIYUN_AREA
  config.aliyun_internal = false
end

def load_file(fname)
  File.open([Rails.root,fname].join("/"))
end
