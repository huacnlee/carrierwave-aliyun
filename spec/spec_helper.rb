require 'rubygems'
require 'rspec'
require 'rspec/autorun'
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

# 测试的时候需要修改这个地方
ALIYUN_ACCESS_ID = "7ewl4zm3mhi45vko9zx022ul"
ALIYUN_ACCESS_KEY = 'Ajpi7IRKDKdXYHHFFoS89uQJQE8='
ALIYUN_BUCKET = "carrierwave"
ALIYUN_HOST = "oss.aliyuncs.com"

CarrierWave.configure do |config|
  config.storage = :aliyun
  config.aliyun_access_id = ALIYUN_ACCESS_ID
  config.aliyun_access_key = ALIYUN_ACCESS_KEY
  config.aliyun_bucket = ALIYUN_BUCKET
  config.aliyun_host = ALIYUN_HOST
  # config.aliyun_internal = false
end

def load_file(fname)
  File.open([Rails.root,fname].join("/"))
end
