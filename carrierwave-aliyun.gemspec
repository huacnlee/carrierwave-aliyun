# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.expand_path('lib/carrierwave/aliyun/version')

Gem::Specification.new do |s|
  s.name        = "carrierwave-aliyun"
  s.version     = CarrierWave::Aliyun::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jason Lee"]
  s.email       = ["huacnlee@gmail.com"]
  s.homepage    = "https://github.com/huacnlee/carrierwave-aliyun"
  s.summary     = %q{Aliyun OSS support for Carrierwave}
  s.description = %q{Aliyun OSS support for Carrierwave}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.license       = 'MIT'

  s.add_dependency "carrierwave", [">= 0.5.7"]
  s.add_dependency "aliyun-oss-sdk", [">= 0.1.6"]
end
