module CarrierWave
  module Aliyun
    class Bucket
      PATH_PREFIX = %r{^/}

      def initialize(uploader)
        @aliyun_access_id    = uploader.aliyun_access_id
        @aliyun_access_key   = uploader.aliyun_access_key
        @aliyun_bucket       = uploader.aliyun_bucket
        @aliyun_area         = uploader.aliyun_area || 'cn-hangzhou'
        @aliyun_private_read = uploader.aliyun_private_read
        @aliyun_internal     = uploader.aliyun_internal

        # Host for get request
        @aliyun_host = uploader.aliyun_host || "https://#{@aliyun_bucket}.oss-#{@aliyun_area}.aliyuncs.com"

        unless @aliyun_host.include?('//')
          raise "config.aliyun_host requirement include // http:// or https://, but you give: #{@aliyun_host}"
        end
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

        begin
          oss_upload_client.put_object(path, headers) do |sw|
            sw << file.read(16 * 1024) until file.eof?
          end
          path_to_url(path)
        rescue => e 
          Rails.logger.error "put failed"
          raise e
        end
      end

      # 读取文件
      # params:
      # - path - remote 存储路径
      # returns:
      # file data
      def get(path)
        path.sub!(PATH_PREFIX, '')
        begin 
          data = nil
          res = oss_upload_client.get_object(path) do |content|
            data = content
          end
          [res, data]
        rescue => e
          Rails.logger.error "get failed"
          raise e
        end
      end

      def get_meta(path)
        path.sub!(PATH_PREFIX, '')
        begin 
          oss_upload_client.get_object(path)
        rescue => e
          nil
        end
      end

      def exists?(path)
        oss_upload_client.object_exists?(path)
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
        begin
          res = oss_upload_client.delete_object(path)
          path_to_url(path)
        rescue => e
          Rails.logger.error "delete failed"
          raise e
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
          url = img_client.object_url(thumb_path, expiry: 3600)
        else
          url = oss_client.object_url(path, expiry: 3600)
        end
        url.gsub('http://', 'https://')
      end

      def head(path)
        obj = img_client.get_object_meta(path)
        # obj.metas
      end

      private

      def oss_client
        return @oss_client if defined?(@oss_client)
        endpoint = "https://oss-#{@aliyun_area}.aliyuncs.com.aliyuncs.com"
        client = ::Aliyun::OSS::Client.new(
          :endpoint => endpoint, 
          :access_key_id => @aliyun_access_id, 
          :access_key_secret => @aliyun_access_key)

        @oss_client = client.get_bucket(@aliyun_bucket)
      end

      def img_client
        return @img_client if defined?(@img_client)
        endpoint = "https://img-#{@aliyun_area}.aliyuncs.com"
        client = ::Aliyun::OSS::Client.new(
          :endpoint => endpoint, 
          :access_key_id => @aliyun_access_id, 
          :access_key_secret => @aliyun_access_key)

        @img_client = client.get_bucket(@aliyun_bucket)
      end

      def oss_upload_client
        return @oss_upload_client if defined?(@oss_upload_client)

        endpoint = if @aliyun_internal
                 "https://oss-#{@aliyun_area}-internal.aliyuncs.com"
               else
                 "https://oss-#{@aliyun_area}.aliyuncs.com"
               end
        client = ::Aliyun::OSS::Client.new(
          :endpoint => endpoint, 
          :access_key_id => @aliyun_access_id, 
          :access_key_secret => @aliyun_access_key)
        @oss_upload_client = client.get_bucket(@aliyun_bucket)
      end
    end
  end
end
