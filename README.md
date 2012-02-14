# CarrierWave for Aliyun OSS

This gem adds support for [Aliyun OSS](http://oss.aliyun.com) to [CarrierWave](https://github.com/jnicklas/carrierwave/)

## Installation

    gem install carrierwave-aliyun

## Using Bundler

    gem 'rest-client'
    gem 'carrierwave-aliyun'

## Configuration

You'll need to configure the to use this in config/initializes/carrierwave.rb

```ruby
CarrierWave.configure do |config|
  config.storage = :aliyun
  config.aliyun_access_id = "xxxxxx"
  config.aliyun_access_key = 'xxxxxx'
  # you need create this bucket first!
  config.aliyun_bucket = "simple"
end
```