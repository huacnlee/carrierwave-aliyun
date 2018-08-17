# CarrierWave for Aliyun OSS

> 根据 [huacnlee/carrierwave-aliyun](https://github.com/huacnlee/carrierwave-aliyun)改造而成，
支持了 [CarrierWave](https://github.com/jnicklas/carrierwave/) 0.3.0以上版本 和 [Aliyun OSS ](http://oss.aliyun.com)1.1.0


> NOTE: 此 Gem 是一个 CarrierWave 的组件，你需要配合 CarrierWave 一起使用，如果你需要直接用 Aliyun OSS，可以尝试用 [aliyun-oss-ruby-sdk](https://github.com/aliyun-beta/aliyun-oss-ruby-sdk) 这个 Gem。

## Using Bundler

```ruby
gem 'carrierwave-aliyun'
```

## Configuration

创建脚本 `config/initializers/carrierwave.rb` 填入下面的代码，并修改对应的配置：

```ruby
CarrierWave.configure do |config|
  config.storage           = :aliyun
  config.aliyun_access_key_id  = "xxxxxx"
  config.aliyun_access_key_secret = 'xxxxxx'
  config.aliyun_bucket     = "simple"
  # 配置存储的地区数据中心
  config.aliyun_region     = "cn-hangzhou"
  config.aliyun_endpoint       = "https://foo.bar.com"
end
```

## 阿里云 OSS 图片缩略图


关于阿里云 OSS 图片缩略图的详细文档，请仔细阅读: [Aliyun OSS 接入图片服务](https://help.aliyun.com/document_detail/44688.html)

```rb
irb> User.last.avatar.url(thumb: '?x-oss-process=image/resize,h_100')
"https://simple.oss-cn-hangzhou.aliyuncs.com/users/avatar/12.png?x-oss-process=image/resize,h_100"
irb> User.last.avatar.url(thumb: '?x-oss-process=image/resize,h_100,w_100')
"https://simple.oss-cn-hangzhou.aliyuncs.com/users/avatar/12.png?x-oss-process=image/resize,h_100,w_100"
```

## 增对文件设置 Content-Disposition

在文件上传的场景（非图片），你可能需要给上传的文件设置 Content-Disposition 以便于用户直接访问 URL 的时候能够用你期望的文件名或原文件名来下载并保存。

这个时候你需要给 Uploader 实现 `content_disposition` 函数，例如：

```rb
# app/uploaders/attachment_uploader.rb
class AttachmentUploader < CarrierWave::Uploader::Base
  def content_disposition
    # 非图片文件，给 content_disposition
    unless file.extension.downcase.in?(%w(jpg jpeg gif png svg))
      "attachment;filename=#{file.original_filename}"
    end
  end
end

```
