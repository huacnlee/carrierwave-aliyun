# encoding: utf-8
require 'carrierwave'
require 'digest/hmac'
require 'digest/md5'
require 'net/http'
require "rest-client"

module CarrierWave
  module Storage
    class Aliyun < Abstract

      class Connection
        def initialize(options={})
          @aliyun_access_id = options[:aliyun_access_id]
          @aliyun_access_key = options[:aliyun_access_key]
          @aliyun_bucket = options[:aliyun_bucket]
          @aliyun_host = "oss.aliyuncs.com"
          if options[:aliyun_internal] == true
            @aliyun_host = "oss-internal.aliyuncs.com"
          end
          @http = Net::HTTP.new(@aliyun_host)
        end

        def put(path, file, options={})
          content_md5 = Digest::MD5.hexdigest(file)
          path = "#{@aliyun_bucket}/#{path}"
          url = "http://#{@aliyun_host}/#{path}"
          headers = generate_header("PUT", path, content_md5, options).merge!({"Content-Length" => file.length})
          RestClient.put url, file, headers
        end

        def get(path, options={})
          path = "#{@aliyun_bucket}/#{path}"
          url = "http://#{@aliyun_host}/#{path}"
          headers = generate_header "GET", path, "", options
          RestClient.get url, headers
        end

        def delete path
          path = "#{@aliyun_bucket}/#{path}"
          url = "http://#{@aliyun_host}/#{path}"
          date = Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")
          headers =           {
              "Authorization" => sign("DELETE", path, "", "", date),
              "Date" => date,
              "Host" => @aliyun_host,
          }
          RestClient.delete url, headers
        end

        private

        def generate_header verb, path , content_md5, options={}
          content_type = options[:content_type] || "image/jpg"
          date = Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")
          auth_sign = sign(verb, path, "", content_type, date)
          {
              "Authorization" => auth_sign,
              "Content-Type" => content_type,
              "Date" => date,
              "Host" => @aliyun_host,
              "Expect" => "100-Continue"
          }
        end

        def sign(verb, path, content_md5 = '', content_type = '', date)
          canonicalized_oss_headers = ''
          canonicalized_resource = "/#{path}"
          string_to_sign = "#{verb}\n\n#{content_type}\n#{date}\n#{canonicalized_oss_headers}#{canonicalized_resource}"
          digest = OpenSSL::Digest::Digest.new('sha1')
          h = OpenSSL::HMAC.digest(digest, @aliyun_access_key, string_to_sign)
          h = Base64.encode64(h)
          "OSS #{@aliyun_access_id}:#{h}"
        end
      end

      class File
        attr_accessor :content_type

        def initialize(uploader, base, path)
          @uploader = uploader
          @path = path
          @base = base
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
          oss_connection.get(@path)
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
            nil
          end
        end

        def url
          "http://oss.aliyuncs.com/#{@uploader.aliyun_bucket}/#{@path}"
        end

        def store(data, opts = {})
          oss_connection.put(@path, data, opts)
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
              :aliyun_access_id => @uploader.aliyun_access_id,
              :aliyun_access_key => @uploader.aliyun_access_key,
              :aliyun_bucket => @uploader.aliyun_bucket
            }
            @oss_connection ||= CarrierWave::Storage::Aliyun::Connection.new(config)
          end

      end

      def store!(file)
        f = CarrierWave::Storage::Aliyun::File.new(uploader, self, uploader.store_path)
        f.store(file.read, :content_type => file.content_type)
        f
      end

      def retrieve!(identifier)
        CarrierWave::Storage::Aliyun::File.new(uploader, self, uploader.store_path(identifier))
      end
    end
  end
end
