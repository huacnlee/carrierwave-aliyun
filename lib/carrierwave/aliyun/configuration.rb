# frozen_string_literal: true

module CarrierWave
  module Aliyun
    module Configuration
      extend ActiveSupport::Concern

      included do
        add_config :aliyun_access_id
        add_config :aliyun_access_key
        add_config :aliyun_bucket
        add_config :aliyun_area
        add_config :aliyun_region
        add_config :aliyun_internal
        add_config :aliyun_host
        add_config :aliyun_private_read

        configure do |config|
          config.storage_engines[:aliyun] = "CarrierWave::Storage::Aliyun"
        end
      end
    end
  end
end
