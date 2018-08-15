module CarrierWave
  module Storage
    class AliyunFile < CarrierWave::SanitizedFile
      attr_reader :path

      def initialize(uploader, base, path)
        @uploader = uploader
        @path     = URI.encode(path)
        @base     = base
      end

      def delete
        bucket.delete(@path)
        true
      rescue => e
        # If the file's not there, don't panic
        puts "carrierwave-aliyun delete file failed: #{e}"
        nil
      end

      def url(opts = {})
        bucket.path_to_url(@path, opts)
      end

      def content_type
        headers[:content_type].first
      end

      def content_type=(new_content_type)
        headers[:content_type] = new_content_type
      end

      def store(file, headers = {})
        bucket.put(@path, file, headers)
      end

      def headers
        @headers ||= {}
      end

      private

      def bucket
        @bucket ||= CarrierWave::Aliyun::Bucket.new(@uploader)
      end
    end
  end
end
