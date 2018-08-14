module CarrierWave
  module Aliyun
    class Bucket
      PATH_PREFIX = %r{^/}

      def initialize(uploader)
        @aliyun_access_id    = uploader.aliyun_access_id
        @aliyun_access_key   = uploader.aliyun_access_key
        @aliyun_endpoint     = uploader.aliyun_endpoint
        @aliyun_bucket       = uploader.aliyun_bucket
        @aliyun_region         = uploader.aliyun_region || 'cn-hangzhou'
        @aliyun_private_read = uploader.aliyun_private_read
        @aliyun_internal     = uploader.aliyun_internal
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
      def put(path, file, opts = {})
        path.sub!(PATH_PREFIX, '')

        headers = {}
        headers['Content-Type'] = opts[:content_type] || 'image/jpg'
        content_disposition = opts[:content_disposition]
        if content_disposition
          headers['Content-Disposition'] = content_disposition
        end

        res = oss_upload_client.bucket_create_object(path, file, headers)
        if res.success?
          path_to_url(path)
        else
          raise 'Put file failed'
        end
      end

      # 读取文件
      # params:
      # - path - remote 存储路径
      # returns:
      # file data
      def get(path)
        path.sub!(PATH_PREFIX, '')
        res = oss_upload_client.bucket_get_object(path)
        if res.success?
          return res
        else
          raise 'Get content faild'
        end
      end

      # 删除 Remote 的文件
      #
      # params:
      # - path - remote 存储路径
      #
      # returns:
      # 图片的下载地址
      def delete(path)
        path.sub!(PATH_PREFIX, '')
        res = oss_upload_client.bucket_delete_object(path)
        if res.success?
          return path_to_url(path)
        else
          raise 'Delete failed'
        end
      end

      ##
      # 根据配置返回完整的上传文件的访问地址
      def path_to_url(path, opts = {})
        if opts[:thumb]
          thumb_path = [path, opts[:thumb]].join('')
          [@aliyun_host, thumb_path].join('/')
        else
          [@aliyun_host, path].join('/')
        end
      end

      # 私有空间访问地址，会带上实时算出的 token 信息
      # 有效期 3600s
      def private_get_url(path, opts = {})
        path.sub!(PATH_PREFIX, '')
        url = ''
        if opts[:thumb]
          thumb_path = [path, opts[:thumb]].join('')
          url = img_client.bucket_get_object_share_link(thumb_path, 3600)
        else
          url = oss_client.bucket_get_object_share_link(path, 3600)
        end
        url.gsub('http://', 'https://')
      end

      def head(path)
        oss_client.bucket_get_meta_object(path)
      end

      private

      def oss_client
        return @oss_client if defined?(@oss_client)
        opts = {
          access_key_id: @aliyun_access_id,
          access_key_secret: @aliyun_access_key,
          endpoint: @aliyun_endpoint,
          bucket: @aliyun_bucket
        }
        @oss_client = ::Aliyun::OSS::Client.new(opts)
      end

      def img_client
        return @img_client if defined?(@img_client)
        opts = {
          access_key_id: @aliyun_access_id,
          access_key_secret: @aliyun_access_key,
          endpoint: "img-#{@aliyun_region}.aliyuncs.com",
          bucket: @aliyun_bucket
        }
        @img_client = ::Aliyun::OSS::Client.new(opts)
      end

      def oss_upload_client
        return @oss_upload_client if defined?(@oss_upload_client)

        endpoint = if @aliyun_internal
                 "oss-#{@aliyun_region}-internal.aliyuncs.com"
               else
                 "oss-#{@aliyun_region}.aliyuncs.com"
               end

        opts = {
          access_key_id: @aliyun_access_id,
          access_key_secret: @aliyun_access_key,
          endpoint: endpoint,
          bucket: @aliyun_bucket
        }

        @oss_upload_client = ::Aliyun::OSS::Client.new(opts)
      end
    end
  end
end
