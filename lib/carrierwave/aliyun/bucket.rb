# frozen_string_literal: true

module CarrierWave
  module Aliyun
    class Bucket
      PATH_PREFIX = %r{^/}
      CHUNK_SIZE = 1024 * 1024

      attr_reader :access_key_id, :access_key_secret, :bucket, :region, :mode, :host

      attr_reader :endpoint, :img_endpoint, :upload_endpoint

      def initialize(uploader)
        if uploader.aliyun_area.present?
          ActiveSupport::Deprecation.warn("config.aliyun_area will deprecation in carrierwave-aliyun 1.1.0, please use `aliyun_region` instead.")
          uploader.aliyun_region ||= uploader.aliyun_area
        end

        if uploader.aliyun_private_read != nil
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
        @host = uploader.aliyun_host || "https://#{self.bucket}.oss-#{self.region}.aliyuncs.com"

        unless @host.include?("//")
          raise "config.aliyun_host requirement include // http:// or https://, but you give: #{self.host}"
        end

        @endpoint = "https://oss-#{self.region}.aliyuncs.com"
        @upload_endpoint = uploader.aliyun_internal == true ? "https://oss-#{self.region}-internal.aliyuncs.com" : @endpoint
        @img_endpoint = "https://img-#{self.region}.aliyuncs.com"
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

        begin
          oss_upload_client.put_object(path, headers: headers) do |stream|
            stream << file.read(CHUNK_SIZE) until file.eof?
          end
          path_to_url(path)
        rescue => e
          raise "Put file failed: #{e}"
        end
      end

      def copy_object(source, dest)
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
      rescue => e
        raise "Get content faild: #{e}"
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
      rescue => e
        raise "Delete failed: #{e}"
      end

      ##
      # 根据配置返回完整的上传文件的访问地址
      def path_to_url(path, thumb: nil)
        path = path.sub(PATH_PREFIX, "")

        if thumb
          [self.host, [path, thumb].join("")].join("/")
        else
          [self.host, path].join("/")
        end
      end

      # 私有空间访问地址，会带上实时算出的 token 信息
      # 有效期 15 minutes
      def private_get_url(path, thumb: nil)
        path = path.sub(PATH_PREFIX, "")

        url = if thumb
                img_client.object_url([path, thumb].join(""), expiry: 15.minutes)
              else
                oss_client.object_url(path, expiry: 15.minutes)
              end

        url.sub("http://", "https://")
      end

      def head(path)
        oss_client.get_object(path)
      end

      private

        def oss_client
          return @oss_client if defined?(@oss_client)
          client = ::Aliyun::OSS::Client.new(endpoint: self.endpoint,
            access_key_id: self.access_key_id, access_key_secret: self.access_key_secret)
          @oss_client = client.get_bucket(self.bucket)
        end

        def img_client
          return @img_client if defined?(@img_client)
          client = ::Aliyun::OSS::Client.new(endpoint: self.img_endpoint,
            access_key_id: self.access_key_id, access_key_secret: self.access_key_secret)
          @img_client = client.get_bucket(self.bucket)
        end

        def oss_upload_client
          return @oss_upload_client if defined?(@oss_upload_client)
          client = ::Aliyun::OSS::Client.new(endpoint: self.upload_endpoint,
            access_key_id: self.access_key_id, access_key_secret: self.access_key_secret)
          @oss_upload_client = client.get_bucket(self.bucket)
        end
    end
  end
end
