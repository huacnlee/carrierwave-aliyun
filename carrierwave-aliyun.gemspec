# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require File.expand_path('lib/carrierwave/aliyun/version')

Gem::Specification.new do |s|
  s.name        = 'carrierwave-aliyun'
  s.version     = CarrierWave::Aliyun::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Jason Lee']
  s.email       = ['huacnlee@gmail.com']
  s.homepage    = 'https://github.com/huacnlee/carrierwave-aliyun'
  s.summary     = 'Aliyun OSS support for Carrierwave'
  s.description = 'Aliyun OSS support for Carrierwave'
  s.files         = Dir.glob('lib/**/*.rb') + %w(README.md CHANGELOG.md)
  s.require_paths = ['lib']
  s.license       = 'MIT'

  s.add_dependency 'carrierwave', ['>= 0.5.7']
  s.add_dependency 'aliyun-sdk', ['>= 0.6.0']

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'sqlite3-ruby'
  s.add_development_dependency 'mini_magick'
  s.add_development_dependency 'rspec'
end
