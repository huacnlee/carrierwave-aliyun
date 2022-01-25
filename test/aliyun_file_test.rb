# frozen_string_literal: true

require "test_helper"

class CarrierWave::Storage::AliyunFileTest < ActiveSupport::TestCase
  setup do
    @uploader = CarrierWave::Uploader::Base.new
    @bucket = CarrierWave::Aliyun::Bucket.new(@uploader)
  end

  test "respond_to identifier, filename" do
    f = CarrierWave::Storage::AliyunFile.new(@uploader, "", "aaa/bbb.jpg")
    assert_equal "aaa/bbb.jpg", f.identifier
    assert_equal "aaa/bbb.jpg", f.filename
    assert_equal "jpg", f.extension
  end

  test "CJK file name" do
    f = rack_upload_file("中文 文件测试.zip", "application/zip")
    file_url = @bucket.put("/hello/中文 文件 100% 测试?a=1&b=2.zip", f, content_type: "application/zip")
    # puts "-------- #{file_url}"
    fname = File.basename(file_url)
    assert_equal "中文 文件 100% 测试?a=1&b=2.zip", CGI.unescape(fname)

    res = download_file(file_url)
    assert_equal "200", res.code
    assert_equal f.size, res.body.size
    assert_equal "application/zip", res["Content-Type"]
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
    %i[content_type server date content_length etag last_modified content_md5].each do |key|
      assert f.headers.key?(key)
    end
    assert_equal "image/jpg", f.content_type

    # copy_to
    new_file = f.copy_to("/a/a-copy.jpg")
    assert_equal true, new_file.exists?
    assert_equal "image/jpg", new_file.headers[:content_type]
    assert_equal local_file.size.to_s, new_file.headers[:content_length]
    assert_equal local_file.size, new_file.size
    assert_equal local_file.size, new_file.read.size
  end
end
