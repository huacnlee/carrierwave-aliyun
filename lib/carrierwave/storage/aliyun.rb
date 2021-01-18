# frozen_string_literal: true

module CarrierWave
  module Storage
    class Aliyun < Abstract
      def store!(new_file)
        f = AliyunFile.new(uploader, self, uploader.store_path)
        headers = {
          content_type: new_file.content_type,
          content_disposition: uploader.try(:content_disposition)
        }

        f.store(new_file, headers)
        f
      end

      def retrieve!(identifier)
        AliyunFile.new(uploader, self, uploader.store_path(identifier))
      end

      def cache!(new_file)
        f = AliyunFile.new(uploader, self, uploader.cache_path)
        headers = {
          content_type: new_file.content_type,
          content_disposition: uploader.try(:content_disposition)
        }

        f.store(new_file, headers)
        f
      end

      def retrieve_from_cache!(identifier)
        AliyunFile.new(uploader, self, uploader.cache_path(identifier))
      end

      def delete_dir!(path)
        # do nothing, because there's no such things as 'empty directory'
      end

      private

      def bucket
        @bucket ||= CarrierWave::Aliyun::Bucket.new(uploader)
      end
    end
  end
end
