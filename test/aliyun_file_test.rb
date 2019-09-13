# frozen_string_literal: true

require "test_helper"

class CarrierWave::Storage::AliyunFileTest < ActiveSupport::TestCase
  setup do
    @uploader = CarrierWave::Uploader::Base.new
    @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)
  end

  test "respond_to identifier, filename" do
    f = CarrierWave::Storage::AliyunFile.new(@uploader, "", "")
    assert f.respond_to?(:identifier)
    assert f.respond_to?(:filename)
  end

  test "read work" do
    local_file = load_file("foo.jpg")
    image_url = @bucket.put("/a/a.jpg", load_file("foo.jpg"))
    res = download_file(image_url)

    @uploader.aliyun_mode = :public
    f = CarrierWave::Storage::AliyunFile.new(@uploader, "", "/a/a.jpg")
    body = f.read
    assert_equal res.body, body

    assert_equal "https://carrierwave-aliyun-test.oss-cn-beijing.aliyuncs.com/a/a.jpg", f.url
    %i(content_type server date content_length etag last_modified content_md5).each do |key|
      assert f.headers.keys.include?(key)
    end
    assert_equal "image/jpg", f.content_type
  end
end
