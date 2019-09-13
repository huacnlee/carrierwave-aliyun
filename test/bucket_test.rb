# frozen_string_literal: true

require "test_helper"

class CarrierWave::Aliyun::BucketTest < ActiveSupport::TestCase
  setup do
    @uploader = CarrierWave::Uploader::Base.new
    @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)
  end

  test "base config" do
    assert_equal ALIYUN_ACCESS_KEY_ID, @bucket.access_key_id
    assert_equal ALIYUN_ACCESS_KEY_ID, @bucket.access_key_id
    assert_equal ALIYUN_ACCESS_KEY_SECRET, @bucket.access_key_secret
    assert_equal ALIYUN_BUCKET, @bucket.bucket
    assert_equal ALIYUN_REGION, @bucket.region
    assert_equal :public, @bucket.mode
    assert_equal "https://#{@bucket.bucket}.oss-#{@bucket.region}.aliyuncs.com", @bucket.host
  end

  test "put" do
    url = @bucket.put("a/a.jpg", load_file("foo.jpg"))
    res = download_file(url)
    assert_equal "200", res.code
  end

  test "put with / prefix" do
    url = @bucket.put("/a/a.jpg", load_file("foo.jpg"))
    res = download_file(url)
    assert_equal "200", res.code
  end

  test "put with custom host" do
    @uploader.aliyun_host = "https://foo.bar.com"
    @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)
    url = @bucket.put("a/a.jpg", load_file("foo.jpg"))
    assert_equal "https://foo.bar.com/a/a.jpg", url

    @uploader.aliyun_host = "http://foo.bar.com"
    @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)
    url = @bucket.put("a/a.jpg", load_file("foo.jpg"))
    assert_equal "http://foo.bar.com/a/a.jpg", url
  end

  test "delete" do
    url = @bucket.delete("/a/a.jpg")
    res = download_file(url)
    assert_equal "404", res.code
  end

  test "private mode" do
    @uploader.aliyun_mode = :private
    @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)

    # should get url include token
    url = @bucket.private_get_url("bar/foo.jpg")
    # http://oss-cn-beijing.aliyuncs.com.//carrierwave-aliyun-test.oss-cn-beijing.aliyuncs.com/bar/foo.jpg?OSSAccessKeyId=1OpWEtPTjIDv5u8q&Expires=1455172009&Signature=4ibgQpfHOjVpqxG6162S8Ar3c6c=
    %w(Signature Expires OSSAccessKeyId).each do |key|
      assert_equal true, url.include?(key)
    end
    assert_equal true, url.include?("https://#{@uploader.aliyun_bucket}.oss-#{@uploader.aliyun_region}.aliyuncs.com/bar/foo.jpg")

    # should get url with :thumb
    url = @bucket.private_get_url("bar/foo.jpg", thumb: "@100w_200h_90q")
    assert_equal true, url.include?("https://#{@uploader.aliyun_bucket}.img-cn-beijing.aliyuncs.com/bar/foo.jpg%40100w_200h_90q")
  end
end
