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

module Rails
  class <<self
    def root
      [File.expand_path(__FILE__).split('/')[0..-3].join('/'), 'spec'].join('/')
    end
  end
end

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ALIYUN_ACCESS_ID  = ENV['ALIYUN_ACCESS_ID'] || ''
ALIYUN_ACCESS_KEY = ENV['ALIYUN_ACCESS_KEY'] || ''
ALIYUN_BUCKET     = ENV['ALIYUN_BUCKET'] || 'carrierwave-aliyun-test'
ALIYUN_REGION     = ENV['ALIYUN_REGION'] || 'cn-beijing'

CarrierWave.configure do |config|
  config.storage           = :aliyun
  config.aliyun_access_id  = ALIYUN_ACCESS_ID
  config.aliyun_access_key = ALIYUN_ACCESS_KEY
  config.aliyun_bucket     = ALIYUN_BUCKET
  config.aliyun_region       = ALIYUN_REGION
  config.aliyun_internal   = false
end

def load_file(fname)
  File.open([Rails.root, fname].join('/'))
end
