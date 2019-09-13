# frozen_string_literal: true

require "minitest/autorun"
require "sqlite3"
require "active_record"
require "carrierwave-aliyun"
require "carrierwave/orm/activerecord"
require "carrierwave/processing/mini_magick"
require "open-uri"
require "net/http"

module Rails
  class <<self
    def root
      [File.expand_path(__FILE__).split("/")[0..-3].join("/"), "test"].join("/")
    end
  end
end

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
# ActiveRecord::Base.configurations = true

ActiveRecord::Schema.verbose = false

ALIYUN_ACCESS_KEY_ID     = ENV["ALIYUN_ACCESS_KEY_ID"] || ""
ALIYUN_ACCESS_KEY_SECRET = ENV["ALIYUN_ACCESS_KEY_SECRET"] || ""
ALIYUN_BUCKET            = "carrierwave-aliyun-test"
ALIYUN_REGION            = "cn-beijing"

CarrierWave.configure do |config|
  config.storage                  = :aliyun
  config.aliyun_access_key_id     = ALIYUN_ACCESS_KEY_ID
  config.aliyun_access_key_secret = ALIYUN_ACCESS_KEY_SECRET
  config.aliyun_bucket            = ALIYUN_BUCKET
  config.aliyun_region            = ALIYUN_REGION
  config.aliyun_internal          = false
end

class PhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  version :small do
    process resize_to_fill: [120, 120]
  end

  def store_dir
    "photos"
  end
end

class AttachUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "attaches"
  end

  def filename
    if super.present?
      @name ||= SecureRandom.uuid
      "#{Time.now.year}/#{@name}.#{file.extension.downcase}"
    end
  end

  def content_disposition
    "attachment;filename=#{file.original_filename}"
  end
end

class Photo < ActiveRecord::Base
  mount_uploader :image, PhotoUploader
end

class Attachment < ActiveRecord::Base
  mount_uploader :file, AttachUploader
end


class ActiveSupport::TestCase
  setup do
    ActiveRecord::Schema.define(version: 1) do
      create_table :photos do |t|
        t.column :image, :string
        t.column :content_type, :string
      end

      create_table :attachments do |t|
        t.column :file, :string
        t.column :content_type, :string
      end
    end
  end

  teardown do
    ActiveRecord::Base.connection.data_sources.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  def load_file(fname)
    File.open([Rails.root, "fixtures", fname].join("/"))
  end

  def download_file(url)
    Net::HTTP.get_response(URI.parse(url))
  end
end
