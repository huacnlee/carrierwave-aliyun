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

  test "with custom host" do
    @uploader.aliyun_host = "https://foo.bar.com"
    @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)
    url = @bucket.put("a/a.jpg", load_file("foo.jpg"))
    assert_equal "https://foo.bar.com/a/a.jpg", url

    # get url
    assert_equal "https://foo.bar.com/foo/bar.jpg", @bucket.path_to_url("/foo/bar.jpg")
    assert_equal "https://foo.bar.com/foo/bar.jpg?x-oss-process=image%2Fresize%2Ch_100", @bucket.path_to_url("/foo/bar.jpg", thumb: "?x-oss-process=image/resize,h_100")
    assert_equal "https://foo.bar.com/foo/bar.jpg!sm", @bucket.path_to_url("/foo/bar.jpg", thumb: "!sm")
    assert_prefix_with "https://foo.bar.com/foo/bar.jpg", @bucket.private_get_url("/foo/bar.jpg")
    assert_prefix_with "https://foo.bar.com/foo/bar.jpg", @bucket.private_get_url("/foo/bar.jpg", thumb: "?x-oss-process=image/resize,h_100")

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
    @uploader.aliyun_host = nil
    @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)

    # should get url include token
    url = @bucket.private_get_url("bar/foo.jpg")
    # http://carrierwave-aliyun-test.oss-cn-beijing.aliyuncs.com/bar/foo.jpg?OSSAccessKeyId=1OpWEtPTjIDv5u8q&Expires=1455172009&Signature=4ibgQpfHOjVpqxG6162S8Ar3c6c=
    %w[Signature Expires OSSAccessKeyId].each do |key|
      assert_equal true, url.include?(key)
    end
    assert_prefix_with "https://#{@uploader.aliyun_bucket}.oss-#{@uploader.aliyun_region}.aliyuncs.com/bar/foo.jpg", url

    # should get url with :thumb
    url = @bucket.private_get_url("bar/foo.jpg", thumb: "?x-oss-process=image/resize,w_192,h_192,m_fill")
    assert_prefix_with "https://#{@uploader.aliyun_bucket}.oss-cn-beijing.aliyuncs.com/bar/foo.jpg?x-oss-process=image%2Fresize%2Cw_192%2Ch_192%2Cm_fill&Expires=", url
  end

  test "head" do
    f = load_file("foo.jpg")
    url = @bucket.put("foo/head-test.jpg", f)
    file = @bucket.head("foo/head-test.jpg")
    assert_kind_of Aliyun::OSS::Object, file
    assert_equal "foo/head-test.jpg", file.key
    assert_equal f.size, file.size
  end

  test "copy_object" do
    f = load_file("foo.jpg")
    url = @bucket.put("foo/source-test.jpg", f)
    @bucket.copy_object("foo/source-test.jpg", "foo/source-test-copy.jpg")

    file = @bucket.head("foo/source-test-copy.jpg")
    assert_kind_of Aliyun::OSS::Object, file
    assert_equal "foo/source-test-copy.jpg", file.key
    assert_equal f.size, file.size
  end
end
