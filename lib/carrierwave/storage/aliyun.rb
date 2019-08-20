# frozen_string_literal: true

module CarrierWave
  module Storage
    class Aliyun < Abstract
      def store!(file)
        f = AliyunFile.new(uploader, self, uploader.store_path)
        headers = {
          content_type: file.content_type,
          content_disposition: uploader.try(:content_disposition)
        }

        f.store(::File.open(file.file), headers)
        f
      end

      def retrieve!(identifier)
        AliyunFile.new(uploader, self, uploader.store_path(identifier))
      end

      def cache!(file)
        f = AliyunFile.new(uploader, self, uploader.store_path)
        headers = {
          content_type: file.content_type,
          content_disposition: uploader.try(:content_disposition)
        }

        f.store(::File.open(file.file), headers)
        f
      end

      def retrieve_from_cache!(identifier)
        AliyunFile.new(uploader, self, uploader.store_path(identifier))
      end

      def delete_dir!(path)
        # do nothing, because there's no such things as 'empty directory'
      end

      def clean_cache!(_seconds)
        raise 'use Object Lifecycle Management to clean the cache'
      end
    end
  end
end
