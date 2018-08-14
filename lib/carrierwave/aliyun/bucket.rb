module CarrierWave
  module Aliyun
    class Bucket
      PATH_PREFIX = %r{^/}

      def initialize(uploader)
        @aliyun_access_key_id    = uploader.aliyun_access_key_id
        @aliyun_access_key_secret   = uploader.aliyun_access_key_secret
        @aliyun_endpoint     = uploader.aliyun_endpoint
        @aliyun_bucket       = uploader.aliyun_bucket
        @aliyun_region         = uploader.aliyun_region
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

        headers = { file: file }
        headers['Content-Type'] = opts[:content_type] || 'image/jpg'
        content_disposition = opts[:content_disposition]
        if content_disposition
          headers['Content-Disposition'] = content_disposition
        end

        res = bucket.put_object(path, headers)
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
        res = bucket.get_object(path)
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
        res = bucket.delete_object(path)
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
          [@aliyun_endpoint, thumb_path].join('/')
        else
          [@aliyun_endpoint, path].join('/')
        end
      end

      private

      def oss_client
        return @oss_client if @oss_client

        opts = {
          access_key_id: @aliyun_access_key_id,
          access_key_secret: @aliyun_access_key,
          endpoint: @aliyun_endpoint,
        }

        @oss_client = ::Aliyun::OSS::Client.new(opts)
      end

      def bucket
        @bucket ||= oss_client.get_bucket(@aliyun_bucket)
      end
    end
  end
end
