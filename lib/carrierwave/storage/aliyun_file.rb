# frozen_string_literal: true

module CarrierWave
  module Storage
    class AliyunFile < CarrierWave::SanitizedFile
      attr_reader :path

      def initialize(uploader, base, path)
        @uploader, @path, @base = uploader, URI.encode(path), base
      end

      def read
        object, body = bucket.get(path)
        @headers = object.headers
        body
      end

      def delete
        bucket.delete(path)
        true
      rescue => e
        # If the file's not there, don't panic
        puts "carrierwave-aliyun delete file failed: #{e}"
        nil
      end

      ##
      # Generate file url
      # params
      #    :thumb - Aliyun OSS Image Processor option, etc: @100w_200h_95q
      #
      def url(opts = {})
        if bucket.mode == :private
          bucket.private_get_url(path, opts)
        else
          bucket.path_to_url(path, opts)
        end
      end

      def content_type
        headers[:content_type]
      end

      def content_type=(new_content_type)
        headers[:content_type] = new_content_type
      end

      def store(new_file, headers = {})
        if new_file.is_a?(self.class)
          new_file.copy_to(path)
        else
          fog_file = new_file.to_file
          bucket.put(path, fog_file, headers)
          fog_file.close if fog_file && !fog_file.closed?
        end
        true
      end

      def headers
        @headers ||= {}
      end

      def file
        @file ||= bucket.get(path)
      end

      def copy_to(new_path)
        bucket.copy_object(self.path, new_path)
        self.class.new(@uploader, @base, new_path)
      end

      private

        def bucket
          @bucket ||= CarrierWave::Aliyun::Bucket.new(@uploader)
        end
    end
  end
end
