require File.dirname(__FILE__) + '/spec_helper'
require "open-uri"
require "net/http"

describe "Aliyun" do
  before(:all) do
    @opts = {
      :aliyun_access_id => ALIYUN_ACCESS_ID,
      :aliyun_access_key => ALIYUN_ACCESS_KEY,
      :aliyun_bucket => ALIYUN_BUCKET,
      :aliyun_area => ALIYUN_AREA,
      :aliyun_internal => false,
      :aliyun_host => "http://bison-dev.cn-hangzhou.oss.aliyun-inc.com"
    }

    @uploader = CarrierWave::Uploader::Base.new
    @connection = CarrierWave::Storage::Aliyun::Connection.new(@uploader)
  end

  # it "should put by internal network" do
  #   @uploader.aliyun_internal = true
  #   @connection = CarrierWave::Storage::Aliyun::Connection.new(@uploader)
  #   puts @connection.to_json
  #   url = @connection.put("/a/a.jpg",load_file("foo.jpg"))
  #   res = Net::HTTP.get_response(URI.parse(url))
  #   puts res.to_json
  #   expect(res.code).to eq "200"
  # end

  it "should put" do
    url = @connection.put("a/a.jpg",load_file("foo.jpg"))
    res = Net::HTTP.get_response(URI.parse(url))
    expect(res.code).to eq "200"
  end

  it "should put with / prefix" do
    url = @connection.put("/a/a.jpg",load_file("foo.jpg"))
    res = Net::HTTP.get_response(URI.parse(url))
    expect(res.code).to eq "200"
  end

  it "should delete" do
    url = @connection.delete("/a/a.jpg")
    res = Net::HTTP.get_response(URI.parse(url))
    expect(res.code).to eq "404"
  end

  it "should support custom domain" do
    @uploader.aliyun_host = "https://foo.bar.com"
    @connection = CarrierWave::Storage::Aliyun::Connection.new(@uploader)
    url = @connection.put("a/a.jpg",load_file("foo.jpg"))
    expect(url).to eq "https://foo.bar.com/a/a.jpg"
    @uploader.aliyun_host = "http://foo.bar.com"
    @connection = CarrierWave::Storage::Aliyun::Connection.new(@uploader)
    url = @connection.put("a/a.jpg",load_file("foo.jpg"))
    expect(url).to eq "http://foo.bar.com/a/a.jpg"
  end

  describe 'private read bucket' do
    before do
      @uploader.aliyun_private_read = true
      @connection = CarrierWave::Storage::Aliyun::Connection.new(@uploader)
    end

    it 'should get url include token' do
      url = @connection.private_get_url('bar/foo.jpg')
      # http://oss-cn-beijing.aliyuncs.com.//carrierwave-aliyun-test.oss-cn-beijing.aliyuncs.com/bar/foo.jpg?OSSAccessKeyId=1OpWEtPTjIDv5u8q&Expires=1455172009&Signature=4ibgQpfHOjVpqxG6162S8Ar3c6c=
      expect(url).to include(*%w(Signature Expires OSSAccessKeyId))
      expect(url).to include "http://#{@uploader.aliyun_bucket}.oss-#{@uploader.aliyun_area}.aliyuncs.com/bar/foo.jpg"
    end
  end

  describe 'File' do
    it 'should have respond_to identifier' do
      f = CarrierWave::Storage::Aliyun::File.new(@uploader, '', '')
      expect(f).to respond_to(:identifier)
      expect(f).to respond_to(:filename)
    end
  end
end
