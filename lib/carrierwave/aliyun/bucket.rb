# frozen_string_literal: true

module CarrierWave
  module Aliyun
    class Bucket
      PATH_PREFIX = %r{^/}.freeze
      CHUNK_SIZE = 1024 * 1024

      attr_reader :access_key_id, :access_key_secret, :bucket, :region, :mode, :host, :endpoint, :upload_endpoint,
                  :get_endpoint

      def initialize(uploader)
        if uploader.aliyun_area.present?
          ActiveSupport::Deprecation.warn("config.aliyun_area will deprecation in carrierwave-aliyun 1.1.0, please use `aliyun_region` instead.")
          uploader.aliyun_region ||= uploader.aliyun_area
        end

        unless uploader.aliyun_private_read.nil?
          ActiveSupport::Deprecation.warn(%(config.aliyun_private_read will deprecation in carrierwave-aliyun 1.1.0, please use `aliyun_mode = :private` instead.))
          uploader.aliyun_mode ||= uploader.aliyun_private_read ? :private : :public
        end

        if uploader.aliyun_access_id.present?
          ActiveSupport::Deprecation.warn(%(config.aliyun_access_id will deprecation in carrierwave-aliyun 1.1.0, please use `aliyun_access_key_id` instead.))
          uploader.aliyun_access_key_id ||= uploader.aliyun_access_id
        end

        if uploader.aliyun_access_key.present?
          ActiveSupport::Deprecation.warn(%(config.aliyun_access_key will deprecation in carrierwave-aliyun 1.1.0, please use `aliyun_access_key_secret` instead.))
          uploader.aliyun_access_key_secret ||= uploader.aliyun_access_key
        end

        @access_key_id     = uploader.aliyun_access_key_id
        @access_key_secret = uploader.aliyun_access_key_secret
        @bucket            = uploader.aliyun_bucket
        @region            = uploader.aliyun_region || "cn-hangzhou"
        @mode              = (uploader.aliyun_mode || :public).to_sym

        # Host for get request
        @endpoint = "https://#{bucket}.oss-#{region}.aliyuncs.com"
        @host = uploader.aliyun_host || @endpoint

        unless @host.include?("//")
          raise "config.aliyun_host requirement include // http:// or https://, but you give: #{host}"
        end

        @get_endpoint = "https://oss-#{region}.aliyuncs.com"
        @upload_endpoint = uploader.aliyun_internal == true ? "https://oss-#{region}-internal.aliyuncs.com" : "https://oss-#{region}.aliyuncs.com"
      end

      # 上传文件
      # params:
      # - path - remote 存储路径
      # - file - 需要上传文件的 File 对象
      # - opts:
      #   - content_type - 上传文件的 MimeType，默认 `image/jpg`
      #   - content_disposition - Content-Disposition
      # returns:
      # 图片的下载地址
      def put(path, file, content_type: "image/jpg", content_disposition: nil)
        path = path.sub(PATH_PREFIX, "")

        headers = {}
        headers["Content-Type"] = content_type
        headers["Content-Disposition"] = content_disposition if content_disposition

        oss_upload_client.put_object(path, headers: headers) do |stream|
          stream << file.read(CHUNK_SIZE) until file.eof?
        end
        path_to_url(path)
      end

      def copy_object(source, dest)
        source = source.sub(PATH_PREFIX, "")
        dest = dest.sub(PATH_PREFIX, "")

        oss_upload_client.copy_object(source, dest)
      end

      # 读取文件
      # params:
      # - path - remote 存储路径
      # returns:
      # file data
      def get(path)
        path = path.sub(PATH_PREFIX, "")
        chunk_buff = []
        obj = oss_upload_client.get_object(path) do |chunk|
          chunk_buff << chunk
        end

        [obj, chunk_buff.join("")]
      end

      # 删除 Remote 的文件
      #
      # params:
      # - path - remote 存储路径
      #
      # returns:
      # 图片的下载地址
      def delete(path)
        path = path.sub(PATH_PREFIX, "")
        oss_upload_client.delete_object(path)
        path_to_url(path)
      end

      ##
      # 根据配置返回完整的上传文件的访问地址
      def path_to_url(path, thumb: nil)
        get_url(path, thumb: thumb)
      end

      # 私有空间访问地址，会带上实时算出的 token 信息
      # 有效期 15 minutes
      def private_get_url(path, thumb: nil)
        get_url(path, private: true, thumb: thumb)
      end

      def get_url(path, private: false, thumb: nil)
        path = path.sub(PATH_PREFIX, "")

        url = if thumb&.start_with?("?")
                # foo.jpg?x-oss-process=image/resize,h_100
                parameters = { "x-oss-process" => thumb.split("=").last }
                oss_client.object_url(path, private, 15.minutes, parameters)
              else
                oss_client.object_url(path, private, 15.minutes)
              end

        url = [url, thumb].join("") if !private && !thumb&.start_with?("?")

        url.sub(endpoint, host)
      end

      def head(path)
        path = path.sub(PATH_PREFIX, "")
        oss_upload_client.get_object(path)
      end

      # list_objects for test
      def list_objects(opts = {})
        oss_client.list_objects(opts)
      end

      private

      def oss_client
        return @oss_client if defined?(@oss_client)

        client = ::Aliyun::OSS::Client.new(endpoint: get_endpoint, access_key_id: access_key_id,
                                           access_key_secret: access_key_secret)
        @oss_client = client.get_bucket(bucket)
      end

      def oss_upload_client
        return @oss_upload_client if defined?(@oss_upload_client)

        client = ::Aliyun::OSS::Client.new(endpoint: upload_endpoint, access_key_id: access_key_id,
                                           access_key_secret: access_key_secret)
        @oss_upload_client = client.get_bucket(bucket)
      end
    end
  end
end
