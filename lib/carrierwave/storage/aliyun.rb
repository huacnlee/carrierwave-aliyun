# encoding: utf-8
require 'carrierwave'
require 'digest/hmac'
require 'digest/md5'
require "rest-client"

module CarrierWave
  module Storage
    class Aliyun < Abstract
      
      class Connection
        def initialize(options={})
          @aliyun_access_id = options[:aliyun_access_id]
          @aliyun_access_key = options[:aliyun_access_key]
          @aliyun_bucket = options[:aliyun_bucket]
        end
        
        def put(path, file)
          content_md5 = Digest::MD5.hexdigest(file)
          content_type = "image/jpg"
          date = Time.now.gmtime.strftime("%a, %d %b %Y %H:%M:%S GMT")
          path = "#{@aliyun_bucket}/#{path}"
          url = "http://oss.aliyuncs.com/#{path}"
          auth_sign = sign("PUT", path, content_md5, content_type ,date)
          headers = {
            "Authorization" => auth_sign, 
            "Content-Type" => content_type,
            "Content-Length" => file.length,
            "Date" => date,
            "Host" => "oss.aliyuncs.com",
            "Expect" => "100-Continue"
          }
          response = RestClient.put(url, file, headers)
        end
        
        def get(path)
          @http.get(path)            
        end
          
      private      
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
          object = oss_connection.get(@path)
          object.data
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

        def store(data)
          oss_connection.put(@path, data)
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
            
            config = {:aliyun_access_id => @uploader.aliyun_access_id, 
              :aliyun_access_key => @uploader.aliyun_access_key, 
              :aliyun_bucket => @uploader.aliyun_bucket
            }
            @oss_connection ||= CarrierWave::Storage::Aliyun::Connection.new(config)
          end

      end
      
      def store!(file)
        f = CarrierWave::Storage::Aliyun::File.new(uploader, self, uploader.store_path)
        f.store(file.read)
        f
      end

      def retrieve!(identifier)
        CarrierWave::Storage::Aliyun::File.new(uploader, self, uploader.store_path(identifier))
      end
    end
  end
end
