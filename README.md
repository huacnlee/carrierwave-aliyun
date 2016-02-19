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
  # 自定于域名请 CNAME 到 you_bucket_name.oss.aliyuncs.com (you_bucket_name 是你的 bucket 的名称)
  config.aliyun_host       = "http://foo.bar.com"
  # Bucket 为私有读取请设置 true，默认 false，以便得到的 URL 是能带有 private 空间访问权限的逻辑
  # config.aliyun_private_read = false
end
```

## 跳过 CarrierWave 直接调用 Aliyun API

如果你有需求想跳过 CarrierWave，直接调用 Aliyun 的接口，可以参看 `spec/aliyun_spec.rb` 里面有例子。
