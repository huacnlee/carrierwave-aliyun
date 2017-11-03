module CarrierWave
  module Storage
    class AliyunFile < CarrierWave::SanitizedFile
      attr_reader :path

      def initialize(uploader, base, path)
        @uploader = uploader
        @path     = URI.encode(path)
        @base     = base
      end

      def response
        @response ||= bucket.get(@path)
      end

      def headers
        @headers ||= response&.[](0)&.deep_transform_keys! { |key| key.underscore.to_sym }
      end

      def read
        @data ||= response&.[](1)
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
        if @uploader.aliyun_private_read
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

      def store(file, headers = {})
        bucket.put(@path, file, headers)
      end

      private

      def bucket
        return @bucket if defined? @bucket

        @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)
      end
    end
  end
end
