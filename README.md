# CarrierWave for Aliyun OSS

This gem adds support for [Aliyun OSS](http://oss.aliyun.com) to [CarrierWave](https://github.com/jnicklas/carrierwave/)

## Installation

```bash
gem install carrierwave-aliyun
```

## Using Bundler

```ruby
gem 'rest-client'
gem 'carrierwave-aliyun'
```

## Configuration

创建这么个脚本 `config/initializes/carrierwave.rb` 填入下面的代码，并修改对应的配置：

```ruby
CarrierWave.configure do |config|
  config.storage = :aliyun
  config.aliyun_access_id = "xxxxxx"
  config.aliyun_access_key = 'xxxxxx'
  # 你需要在 Aliyum OSS 上面提前创建一个 Bucket
  config.aliyun_bucket = "simple"
  # 是否使用内部连接，true - 使用 Aliyun 局域网的方式访问  false - 外部网络访问
  config.aliyun_internal = true
end
```