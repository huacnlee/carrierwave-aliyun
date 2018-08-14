module CarrierWave
  module Aliyun
    module Configuration
      extend ActiveSupport::Concern

      included do
        add_config :aliyun_access_key_id
        add_config :aliyun_access_key_secret
        add_config :aliyun_endpoint
        add_config :aliyun_bucket
        add_config :aliyun_region

        configure do |config|
          config.storage_engines[:aliyun] = 'CarrierWave::Storage::Aliyun'
        end
      end
    end
  end
end
