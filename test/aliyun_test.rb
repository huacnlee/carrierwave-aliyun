# frozen_string_literal: true

require "test_helper"

class CarrierWave::Storage::AliyunTest < ActiveSupport::TestCase
  # test "store!" do
  #   f = load_file("foo.jpg")
  #   uploader = AttachUploader.new
  #   uploader.store!(f)
  #
  #   assert_match /\/attaches\//, uploader.url
  #   attach = open(uploader.url)
  #   assert_equal f.size, attach.size
  # end

  test "upload image" do
    @file = load_file("foo.jpg")
    @file1 = load_file("foo.gif")
    @photo = Photo.new(image: @file)
    @photo1 = Photo.new(image: @file1)

    assert_equal true, @photo.save!
    assert_equal "foo.jpg", @photo[:image]
    # assert_equal true, @photo.image?

    # FIXME: 不知为何，在 test 里面 @photo.image.url 如果不 reload 将会是 cache url
    # 而实际项目中没有这样的问题，这里强制 reload 避开
    assert_match "/photos/foo.jpg", @photo.image.url

    img = URI.open(@photo.image.url)
    assert_equal @file.size, img.size
    assert_equal "image/jpeg", img.content_type

    # get small version uploaded file
    assert_match "/photos/small_foo.jpg", @photo.image.small.url
    small_file = URI.open(@photo.image.small.url)
    assert_equal true, small_file.size > 0

    assert_equal true, @photo1.save!
    img1 = URI.open(@photo1.image.url)
    assert_equal @file1.size, img1.size
    assert_equal "image/gif", img1.content_type

    assert_no_cache_files @photo.image

    # get Aliyun OSS thumb url with :thumb option
    url = @photo.image.url(thumb: "?x-oss-process=image/resize,w_100")
    uri = URI.parse(url)
    assert_prefix_with "https://carrierwave-aliyun-test.oss-cn-beijing.aliyuncs.com", url
    assert_equal "x-oss-process=image%2Fresize%2Cw_100", uri.query

    url1 = @photo.image.url(thumb: "?x-oss-process=image/resize,w_60")
    uri = URI.parse(url1)
    assert_prefix_with "https://carrierwave-aliyun-test.oss-cn-beijing.aliyuncs.com", url1
    assert_equal "x-oss-process=image%2Fresize%2Cw_60", uri.query

    img1 = URI.open(url)
    assert_equal true, img1.size > 0
    assert_equal "image/jpeg", img1.content_type
  end

  test "upload CJK file name" do
    f = rack_upload_file("中文 文件测试.zip", "application/zip")
    attachment = Attachment.new(file: f)
    attachment.save!

    assert_no_cache_files attachment.file

    file_url = attachment.file.url
    # puts "-------- #{file_url}"
    res = download_file(file_url)
    assert_equal "200", res.code
    assert_equal f.size, res.body.size
    assert_equal "application/zip", res["Content-Type"]
  end

  test "upload a non image file" do
    f = load_file("foo.zip")
    attachment = Attachment.new(file: f)

    # should save
    attachment.save!

    # download and check response
    assert_match(%r{/attaches/}, attachment.file.url)

    attach = URI.open(attachment.file.url)
    assert_equal f.size, attach.size
    assert_equal "application/zip", attach.content_type
    assert_equal "attachment;filename=foo.zip", attach.meta["content-disposition"]
  end
end
