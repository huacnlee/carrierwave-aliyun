require 'aliyun/oss'
require 'carrierwave'
require 'uri'

module CarrierWave
  module Storage
    class Aliyun < Abstract
      def store!(file)
        f = AliyunFile.new(uploader, self, uploader.store_path)
        f.store(::File.open(file.file), content_type: file.content_type)
        f
      end

      def retrieve!(identifier)
        AliyunFile.new(uploader, self, uploader.store_path(identifier))
      end
    end
  end
end
