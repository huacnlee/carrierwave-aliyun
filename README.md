# CarrierWave for Aliyun OSS

This gem adds support for [Aliyun OSS](http://oss.aliyun.com) to [CarrierWave](https://github.com/jnicklas/carrierwave/)

[![Gem Version](https://badge.fury.io/rb/carrierwave-aliyun.svg)](https://rubygems.org/gems/carrierwave-aliyun) [![build](https://github.com/huacnlee/carrierwave-aliyun/workflows/build/badge.svg)](https://github.com/huacnlee/carrierwave-aliyun/actions?query=workflow%3Abuild)

> NOTE: 此 Gem 是一个 CarrierWave 的组件，你需要配合 CarrierWave 一起使用，如果你需要直接用 Aliyun OSS，可以尝试用 [aliyun-sdk](https://github.com/aliyun/aliyun-oss-ruby-sdk) 这个 Gem。

> NOTE: This gem is a extends for [CarrierWave](https://github.com/jnicklas/carrierwave/) for allow it support use Alicloud OSS as storage backend, if you wants use Alicloud OSS directly, please visit [aliyun-sdk](https://github.com/aliyun/aliyun-oss-ruby-sdk).

## Using Bundler

```ruby
gem 'carrierwave-aliyun'
```

## Configuration

You need a `config/initializers/carrierwave.rb` for initialize, and update your configurations:

```ruby
CarrierWave.configure do |config|
  config.storage           = :aliyun
  config.aliyun_access_key_id  = "xxxxxx"
  config.aliyun_access_key_secret = 'xxxxxx'
  # 你需要在 Aliyun OSS 上面提前创建一个 Bucket
  # You must create a Bucket on Alicloud OSS first.
  config.aliyun_bucket     = "simple"
  # 是否使用内部连接，true - 使用 Aliyun 主机内部局域网的方式访问  false - 外部网络访问
  # When your app server wants deployment in Alicloud internal network, enable this option can speed up uploading by using internal networking. otherwice you must disable it.
  config.aliyun_internal   = true
  # 配置存储的地区数据中心，默认: "cn-hangzhou"
  # Which region of your Bucket.
  # config.aliyun_region     = "cn-hangzhou"
  # 使用自定义域名，设定此项，carrierwave 返回的 URL 将会用自定义域名
  # 自定义域名请 CNAME 到 you_bucket_name.oss-cn-hangzhou.aliyuncs.com (you_bucket_name 是你的 bucket 的名称)
  # aliyun_host allow you config a custom host for your Alicloud Bucket, and you also need config that on Alicloud.
  config.aliyun_host       = "https://foo.bar.com"
  # Bucket 为私有读取请设置 true，默认 false，以便得到的 URL 是能带有 private 空间访问权限的逻辑
  # Tell SDK the privacy of you Bucket, if private CarrierWave xxx.url will generate URL with a expires parameter, default: :public.
  # config.aliyun_mode = :private
end
```

## 阿里云 OSS 图片缩略图 / About the image Thumb service for Alicloud OSS

> NOTE: 此方法同样支持 Private 的 Bucket 哦！

> NOTE: Private Bucket also support this feature!

关于阿里云 OSS 图片缩略图的详细文档，请仔细阅读：[Aliyun OSS 接入图片服务](https://help.aliyun.com/document_detail/44688.html)

The details of the Alicoud OSS image thumb service, please visit [Alicloud OSS - Image Processing / Resize images](https://www.alibabacloud.com/help/doc-detail/44688.htm)

```rb
irb> User.last.avatar.url(thumb: '?x-oss-process=image/resize,h_100')
"https://simple.oss-cn-hangzhou.aliyuncs.com/users/avatar/12.png?x-oss-process=image/resize,h_100"
irb> User.last.avatar.url(thumb: '?x-oss-process=image/resize,h_100,w_100')
"https://simple.oss-cn-hangzhou.aliyuncs.com/users/avatar/12.png?x-oss-process=image/resize,h_100,w_100"
```

## 增对文件设置 Content-Disposition / Customize the Content-Disposition

在文件上传的场景（非图片），你可能需要给上传的文件设置 `Content-Disposition` 以便于用户直接访问 URL 的时候能够用你期望的文件名或原文件名来下载并保存。

In some case, you may need change the `Content-Disposition` for your uploaded files for allow users visit URL with direct download, and get the original filename.

这个时候你需要给 Uploader 实现 `content_disposition` 函数，例如：

So, you need implement a `content_disposition` method for your CarrierWave Uploader, for example:

```rb
# app/uploaders/attachment_uploader.rb
class AttachmentUploader < CarrierWave::Uploader::Base
  def content_disposition
    # Only for non-image files
    unless file.extension.downcase.in?(%w(jpg jpeg gif png svg))
      "attachment;filename=#{file.original_filename}"
    end
  end
end
```

## 启用全球传输加速

阿里云允许我们通过 `oss-accelerate.aliyuncs.com` 的节点来实现全球的传输加速，如果你的需要在境外的服务器传输到国内，或许需要开启这个功能。

你只需要将 CarrierWave Aliyun 的 `aliyun_region` 配置为 `accelerate` 即可。

```rb
config.aliyun_region = "accelerate"
```

### 异常解析

> 错误：OSS Transfer Acceleration is not configured on this bucket.
> 确保有开启 [传输加速](https://help.aliyun.com/document_detail/131312.html)，进入 Bucket / 传输管理 / 传输加速 / 开启传输加速。

额外注意：Aliyun OSS 开启传输加速后需要 **30 分钟内全网生效**
