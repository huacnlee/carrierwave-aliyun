# frozen_string_literal: true

require File.dirname(__FILE__) + "/spec_helper"

describe "Aliyun" do
  before do
    @uploader = CarrierWave::Uploader::Base.new
    @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)
  end

  # it "should put by internal network" do
  #   @uploader.aliyun_internal = true
  #   @connection = CarrierWave::Storage::Aliyun.new(@uploader)
  #   puts @connection.to_json
  #   url = @connection.put("/a/a.jpg",load_file("foo.jpg"))
  #   res = Net::HTTP.get_response(URI.parse(url))
  #   puts res.to_json
  #   expect(res.code).to eq "200"
  # end

  it "should base config work" do
    expect(@bucket.access_key_id).to eq(ALIYUN_ACCESS_KEY_ID)
    expect(@bucket.access_key_secret).to eq(ALIYUN_ACCESS_KEY_SECRET)
    expect(@bucket.bucket).to eq(ALIYUN_BUCKET)
    expect(@bucket.region).to eq(ALIYUN_REGION)
    expect(@bucket.mode).to eq(:public)
    expect(@bucket.host).to eq("https://#{@bucket.bucket}.oss-#{@bucket.region}.aliyuncs.com")
  end

  it "should put" do
    url = @bucket.put("a/a.jpg", load_file("foo.jpg"))
    res = Net::HTTP.get_response(URI.parse(url))
    expect(res.code).to eq "200"
  end

  it "should put with / prefix" do
    url = @bucket.put("/a/a.jpg", load_file("foo.jpg"))
    res = Net::HTTP.get_response(URI.parse(url))
    expect(res.code).to eq "200"
  end

  it "should delete" do
    url = @bucket.delete("/a/a.jpg")
    res = Net::HTTP.get_response(URI.parse(url))
    expect(res.code).to eq "404"
  end

  it "should support custom domain" do
    @uploader.aliyun_host = "https://foo.bar.com"
    @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)
    url = @bucket.put("a/a.jpg", load_file("foo.jpg"))
    expect(url).to eq "https://foo.bar.com/a/a.jpg"
    @uploader.aliyun_host = "http://foo.bar.com"
    @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)
    url = @bucket.put("a/a.jpg", load_file("foo.jpg"))
    expect(url).to eq "http://foo.bar.com/a/a.jpg"
  end

  describe "private read bucket" do
    before do
      @uploader.aliyun_mode = :private
      @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)
    end

    it "should get url include token" do
      url = @bucket.private_get_url("bar/foo.jpg")
      # http://oss-cn-beijing.aliyuncs.com.//carrierwave-aliyun-test.oss-cn-beijing.aliyuncs.com/bar/foo.jpg?OSSAccessKeyId=1OpWEtPTjIDv5u8q&Expires=1455172009&Signature=4ibgQpfHOjVpqxG6162S8Ar3c6c=
      expect(url).to include(*%w(Signature Expires OSSAccessKeyId))
      expect(url).to include "https://#{@uploader.aliyun_bucket}.oss-#{@uploader.aliyun_region}.aliyuncs.com/bar/foo.jpg"
    end

    it "should get url with :thumb" do
      url = @bucket.private_get_url("bar/foo.jpg", thumb: "@100w_200h_90q")
      expect(url).to include "https://#{@uploader.aliyun_bucket}.img-cn-beijing.aliyuncs.com/bar/foo.jpg%40100w_200h_90q"
    end
  end

  describe "File" do
    it "should have respond_to identifier" do
      f = CarrierWave::Storage::AliyunFile.new(@uploader, "", "")
      expect(f).to respond_to(:identifier)
      expect(f).to respond_to(:filename)
    end

    it "read work" do
      image_url = @bucket.put("/a/a.jpg", load_file("foo.jpg"))
      res = Net::HTTP.get_response(URI.parse(image_url))

      @uploader.aliyun_mode = :public
      f = CarrierWave::Storage::AliyunFile.new(@uploader, "", "/a/a.jpg")
      body = f.read
      expect(body).to eq(res.body)
      expect(f.url).to eq("https://carrierwave-aliyun-test.oss-cn-beijing.aliyuncs.com/a/a.jpg")
      expect(f.headers.keys).to include(*%i(content_type server date content_length etag last_modified content_md5))
      expect(f.content_type).to eq("image/jpg")
    end
  end
end
