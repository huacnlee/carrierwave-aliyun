# CarrierWave for Aliyun OSS

This gem adds support for [Aliyun OSS](http://oss.aliyun.com) to [CarrierWave](https://github.com/jnicklas/carrierwave/)

[![Gem Version](https://badge.fury.io/rb/carrierwave-aliyun.svg)](https://rubygems.org/gems/carrierwave-aliyun) [![Build Status](https://travis-ci.org/huacnlee/carrierwave-aliyun.svg?branch=master)](https://travis-ci.org/huacnlee/carrierwave-aliyun)

> NOTE: 此 Gem 是一个 CarrierWave 的组件，你需要配合 CarrierWave 一起使用，如果你需要直接用 Aliyun OSS，可以尝试用 [aliyun-oss-ruby-sdk](https://github.com/aliyun-beta/aliyun-oss-ruby-sdk) 这个 Gem。

## Using Bundler

```ruby
gem 'carrierwave-aliyun'
```

## Configuration

创建这么个脚本 `config/initializers/carrierwave.rb` 填入下面的代码，并修改对应的配置：

```ruby
CarrierWave.configure do |config|
  config.storage           = :aliyun
  config.aliyun_access_id  = "xxxxxx"
  config.aliyun_access_key = 'xxxxxx'
  # 你需要在 Aliyum OSS 上面提前创建一个 Bucket
  config.aliyun_bucket     = "simple"
  # 是否使用内部连接，true - 使用 Aliyun 主机内部局域网的方式访问  false - 外部网络访问
  config.aliyun_internal   = true
  # 配置存储的地区数据中心，默认: cn-hangzhou
  # config.aliyun_area     = "cn-hangzhou"
  # 使用自定义域名，设定此项，carrierwave 返回的 URL 将会用自定义域名
  # 自定于域名请 CNAME 到 you_bucket_name.oss-cn-hangzhou.aliyuncs.com (you_bucket_name 是你的 bucket 的名称)
  config.aliyun_host       = "http://foo.bar.com"
  # 配置缩略图 Host，默认 #{aliyun_bucket}.img-#{aliyun_area}.aliyuncs.com
  # config.aliyun_img_host   = "http://you_bucket_name.img-cn-hangzhou.aliyuncs.com"
  # Bucket 为私有读取请设置 true，默认 false，以便得到的 URL 是能带有 private 空间访问权限的逻辑
  # config.aliyun_private_read = false
end
```

## 阿里云 OSS 图片缩略图

从 **0.5.0** 版本开始，carrierwave-aliyun 支持 Aliyun OSS 的图片缩略图了，你只需要在 Uploader 对象的 `url` 函数后面跟上 `:thumb` 附带缩略图参数就可以了。

> NOTE: 此方法同样支持 Private 的 Bucket 哦！

关于阿里云 OSS 图片缩略图的详细文档，请仔细阅读: [Aliyun OSS 接入图片服务](https://help.aliyun.com/document_detail/32210.html)

```rb
irb> User.last.avatar.url(thumb: '@100w_1c')
https://simple.img-cn-hangzhou.aliyuncs.com/users/avatar/12.png@100w_1c
irb> User.last.avatar.url(thumb: '@100w_200h_1c.jpg')
https://simple.img-cn-hangzhou.aliyuncs.com/users/avatar/12.png@100w_200h_1c.jpg
irb> User.last.avatar.url(thumb: '@100w_200h_1c_95q')
https://simple.img-cn-hangzhou.aliyuncs.com/users/avatar/12.png@100w_200h_1c_95q
# 你也可以用自定义的缩略图格式
irb> User.last.avatar.url(thumb: '@!large')
```
