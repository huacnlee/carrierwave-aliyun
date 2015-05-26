# encoding: utf-8
require 'carrierwave'
require 'digest/md5'
require 'openssl'
require 'uri'
require "rest-client"

module CarrierWave
  module Storage
    class Aliyun < Abstract

      class Connection
        def initialize(options={})
          @aliyun_access_id   = options[:aliyun_access_id]
          @aliyun_access_key  = options[:aliyun_access_key]
          @aliyun_bucket      = options[:aliyun_bucket]
          @aliyun_area        = options[:aliyun_area] || 'cn-hangzhou'
          @aliyun_upload_host = options[:aliyun_upload_host]

          # Host for upload
          if @aliyun_upload_host.nil?
            if options[:aliyun_internal] == true
              @aliyun_upload_host = "http://#{@aliyun_bucket}.oss-#{@aliyun_area}-internal.aliyuncs.com"
            else
              @aliyun_upload_host = "http://#{@aliyun_bucket}.oss-#{@aliyun_area}.aliyuncs.com"
            end
          end

          # Host for get request
          @aliyun_host = options[:aliyun_host] || "http://#{@aliyun_bucket}.oss-#{@aliyun_area}.aliyuncs.com"

          if not @aliyun_host.include?("http")
            raise "config.aliyun_host requirement include http:// or https://, but you give: #{@aliyun_host}"
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
        def put(path, file, options={})
          path         = format_path(path)
          bucket_path  = get_bucket_path(path)
          content_md5  = Digest::MD5.file(file)
          content_type = options[:content_type] || "image/jpg"
          date         = gmtdate
          url          = path_to_url(path)
          
          host = URI.parse(url).host

          auth_sign    = sign("PUT", bucket_path, content_md5, content_type,date)
          headers      = {
            "Authorization"  => auth_sign,
            "Content-Type"   => content_type,
            "Content-Length" => file.size,
            "Date"           => date,
            "Host"           => host,
            "Expect"         => "100-Continue"
          }

          RestClient.put(URI.encode(url).gsub("+", "%2B"), file, headers)
          return path_to_url(path, :get => true)
        end

        # 读取文件
        # params:
        # - path - remote 存储路径
        # returns:
        # file data
        def get(path)
          path = format_path(path)
          url  = path_to_url(path)
          RestClient.get(URI.encode(url))
        end

        # 删除 Remote 的文件
        #
        # params:
        # - path - remote 存储路径
        #
        # returns:
        # 图片的下载地址
        def delete(path)
          path        = format_path(path)
          bucket_path = get_bucket_path(path)
          date        = gmtdate
          url         = path_to_url(path)
          host        = URI.parse(url).host
          headers     = {
            "Host"          => host,
            "Date"          => date,
            "Authorization" => sign("DELETE", bucket_path, "", "" ,date)
          }
          
          RestClient.delete(URI.encode(url).gsub("+", "%2B"), headers)
          return path_to_url(path, :get => true)
        end

        #
        # 阿里云需要的 GMT 时间格式
        def gmtdate
          Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")
        end

        def format_path(path)
          return "" if path.blank?
          path.gsub!(/^\//,"")

          path
        end

        def get_bucket_path(path)
          [@aliyun_bucket,path].join("/")
        end

        ##
        # 根据配置返回完整的上传文件的访问地址
        def path_to_url(path, opts = {})
          if opts[:get]
            "#{@aliyun_host}/#{path}"
          else
            "#{@aliyun_upload_host}/#{path}"
          end
        end

        private
        def sign(verb, path, content_md5 = '', content_type = '', date)
          canonicalized_oss_headers = ''
          canonicalized_resource = "/#{path}"
          string_to_sign = "#{verb}\n\n#{content_type}\n#{date}\n#{canonicalized_oss_headers}#{canonicalized_resource}"
          digest = OpenSSL::Digest.new('sha1')
          h = OpenSSL::HMAC.digest(digest, @aliyun_access_key, string_to_sign)
          h = Base64.encode64(h)
          "OSS #{@aliyun_access_id}:#{h}"
        end
      end

      class File < CarrierWave::SanitizedFile
        def initialize(uploader, base, path)
          @uploader = uploader
          @path     = path
          @base     = base
        end

        ##
        # Returns the current path/filename of the file on Cloud Files.
        #
        # === Returns
        #
        # [String] A path
        #
        def path
          @path
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
          begin
            oss_connection.delete(@path)
            true
          rescue Exception => e
            # If the file's not there, don't panic
            puts "carrierwave-aliyun delete file failed: #{e}"
            nil
          end
        end

        def url
          oss_connection.path_to_url(@path, :get => true)
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

        def extension
          @path.split('.').last
        end

        private

          def headers
            @headers ||= {  }
          end

          def connection
            @base.connection
          end

          def oss_connection
            return @oss_connection if @oss_connection

            config = {
              :aliyun_access_id  => @uploader.aliyun_access_id,
              :aliyun_access_key => @uploader.aliyun_access_key,
              :aliyun_area       => @uploader.aliyun_area,
              :aliyun_bucket     => @uploader.aliyun_bucket,
              :aliyun_internal   => @uploader.aliyun_internal,
              :aliyun_host       => @uploader.aliyun_host,
              :aliyun_upload_host => @uploader.aliyun_upload_host
            }
            @oss_connection ||= CarrierWave::Storage::Aliyun::Connection.new(config)
          end

      end

      def store!(file)
        f = CarrierWave::Storage::Aliyun::File.new(uploader, self, uploader.store_path)
        f.store(::File.open(file.file), :content_type => file.content_type)
        f
      end

      def retrieve!(identifier)
        CarrierWave::Storage::Aliyun::File.new(uploader, self, uploader.store_path(identifier))
      end
    end
  end
end
