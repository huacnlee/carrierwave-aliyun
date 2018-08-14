require 'aliyun/oss'
require 'carrierwave'
require 'uri'

module CarrierWave
  module Storage
    class Aliyun < Abstract
      def store!(file)
        f = AliyunFile.new(uploader, self, uploader.store_path)
        headers = {
          content_type: file.content_type,
          content_disposition: uploader.try(:content_disposition)
        }

        f.store(file.file, headers)
        f
      end

      def retrieve!(identifier)
        AliyunFile.new(uploader, self, uploader.store_path(identifier))
      end
    end
  end
end
