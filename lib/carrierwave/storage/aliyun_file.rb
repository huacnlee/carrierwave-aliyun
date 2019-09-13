# frozen_string_literal: true

module CarrierWave
  module Storage
    class AliyunFile < CarrierWave::SanitizedFile
      attr_reader :path

      def initialize(uploader, base, path)
        @uploader = uploader
        @path     = URI.encode(path)
        @base     = base
      end

      def read
        object, body = bucket.get(@path)
        @headers = object.headers
        body
      end

      def delete
        bucket.delete(@path)
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
          bucket.private_get_url(@path, opts)
        else
          bucket.path_to_url(@path, opts)
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
          new_file.move_to(path)
        else
          bucket.put(@path, new_file, headers)
        end
      end

      def headers
        @headers ||= {}
      end

      private

        def bucket
          return @bucket if defined? @bucket

          @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)
        end
    end
  end
end
