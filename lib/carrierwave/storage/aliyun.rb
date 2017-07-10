require 'aliyun/oss'
require 'carrierwave'
require 'uri'

module CarrierWave
  module Storage
    class Aliyun < Abstract
      def store!(file)
        f = AliyunFile.new(uploader, self, uploader.store_path)
        headers = {
          content_type: file.content_type
        }.merge(get_custom_headers)

        f.store(::File.open(file.file), headers)
        f
      end

      def retrieve!(identifier)
        AliyunFile.new(uploader, self, uploader.store_path(identifier))
      end

      private

      def get_custom_headers
        return uploader.custom_headers if uploader.custom_headers.is_a?(Hash)
        return uploader.custom_headers.call(uploader) if uploader.custom_headers.respond_to?(:call)
        uploader.custom_headers.to_h
      ensure
        {}
      end
    end
  end
end
