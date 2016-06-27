require 'aliyun/oss'
require 'carrierwave'
require 'uri'

module CarrierWave
  module Storage
    class Aliyun < Abstract
      class Connection
        PATH_PREFIX = %r{^/}

        def initialize(uploader)
          @uploader = uploader
          @aliyun_access_id    = uploader.aliyun_access_id
          @aliyun_access_key   = uploader.aliyun_access_key
          @aliyun_bucket       = uploader.aliyun_bucket
          @aliyun_area         = uploader.aliyun_area || 'cn-hangzhou'
          @aliyun_private_read = uploader.aliyun_private_read

          # Host for get request
          @aliyun_host = uploader.aliyun_host || "http://#{@aliyun_bucket}.oss-#{@aliyun_area}.aliyuncs.com"
          @aliyun_img_host = uploader.aliyun_img_host || "http://#{@aliyun_bucket}.img-#{@aliyun_area}.aliyuncs.com"

          unless @aliyun_host.include?('//')
            fail "config.aliyun_host requirement include // http:// or https://, but you give: #{@aliyun_host}"
          end
        end

        # 上传文件
        # params:
        # - path - remote 存储路径
        # - file - 需要上传文件的 File 对象
        # - options:
        #   - content_type - 上传文件的 MimeType，默认 `image/jpg`
        # returns:
        # 图片的下载地址
        def put(path, file, options = {})
          path.sub!(PATH_PREFIX, '')
          opts = {
            'Content-Type' => options[:content_type] || 'image/jpg'
          }

          res = oss_upload_client.bucket_create_object(path, file, opts)
          if res.success?
            path_to_url(path)
          else
            fail 'Put file failed'
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
            return res.parsed_response
          else
            fail 'Get content faild'
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
            fail 'Delete failed'
          end
        end

        ##
        # 根据配置返回完整的上传文件的访问地址
        def path_to_url(path, opts = {})
          if opts[:thumb]
            thumb_path = [path, opts[:thumb]].join('')
            [@aliyun_img_host, thumb_path].join('/')
          else
            [@aliyun_host, path].join('/')
          end
        end

        # 私有空间访问地址，会带上实时算出的 token 信息
        # 有效期 3600s
        def private_get_url(path, opts = {})
          path.sub!(PATH_PREFIX, '')
          if opts[:thumb]
            thumb_path = [path, opts[:thumb]].join('')
            img_client.bucket_get_object_share_link(thumb_path, 3600)
          else
            oss_client.bucket_get_object_share_link(path, 3600)
          end
        end

        private

        def oss_client
          return @oss_client if defined?(@oss_client)
          opts = {
            host: "oss-#{@aliyun_area}.aliyuncs.com",
            bucket: @aliyun_bucket
          }
          @oss_client = ::Aliyun::Oss::Client.new(@aliyun_access_id, @aliyun_access_key, opts)
        end

        def img_client
          return @img_client if defined?(@img_client)
          opts = {
            host: "img-#{@aliyun_area}.aliyuncs.com",
            bucket: @aliyun_bucket
          }
          @img_client = ::Aliyun::Oss::Client.new(@aliyun_access_id, @aliyun_access_key, opts)
        end

        def oss_upload_client
          return @oss_upload_client if defined?(@oss_upload_client)

          # TODO: 实现根据 config.aliyun_internal 来使用内部 host 上传
          host = "oss-#{@aliyun_area}.aliyuncs.com"

          opts = {
            host: host,
            bucket: @aliyun_bucket
          }

          @oss_upload_client = ::Aliyun::Oss::Client.new(@aliyun_access_id, @aliyun_access_key, opts)
        end
      end

      class File < CarrierWave::SanitizedFile
        ##
        # Returns the current path/filename of the file on Cloud Files.
        #
        # === Returns
        #
        # [String] A path
        #
        attr_reader :path

        def initialize(uploader, base, path)
          @uploader = uploader
          @path     = URI.encode(path)
          @base     = base
        end

        ##
        # Reads the contents of the file from Cloud Files
        #
        # === Returns
        #
        # [String] contents of the file
        #
        def read
          object = oss_connection.get(@path)
          @headers = object.headers
          object.body
        end

        ##
        # Remove the file from Cloud Files
        #
        def delete
          oss_connection.delete(@path)
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
            oss_connection.private_get_url(@path, opts)
          else
            oss_connection.path_to_url(@path, opts)
          end
        end

        def content_type
          headers[:content_type]
        end

        def content_type=(new_content_type)
          headers[:content_type] = new_content_type
        end

        def store(file, opts = {})
          oss_connection.put(@path, file, opts)
        end

        private

        def headers
          @headers ||= {}
        end

        def connection
          @base.connection
        end

        def oss_connection
          return @oss_connection if defined? @oss_connection

          @oss_connection = CarrierWave::Storage::Aliyun::Connection.new(@uploader)
        end
      end

      def store!(file)
        f = CarrierWave::Storage::Aliyun::File.new(uploader, self, uploader.store_path)
        f.store(::File.open(file.file), content_type: file.content_type)
        f
      end

      def retrieve!(identifier)
        CarrierWave::Storage::Aliyun::File.new(uploader, self, uploader.store_path(identifier))
      end
    end
  end
end
