require File.dirname(__FILE__) + '/spec_helper'
require "open-uri"
require "net/http"

describe "Aliyun" do
  before(:all) do
    @opts = {
      :aliyun_access_id => ALIYUN_ACCESS_ID,
      :aliyun_access_key => ALIYUN_ACCESS_KEY,
      :aliyun_bucket => ALIYUN_BUCKET,
      :aliyun_area => "cn-hangzhou",
      :aliyun_internal => true,
      :aliyun_host => "http://bison-dev.cn-hangzhou.oss.aliyun-inc.com"
    }
    @connection = CarrierWave::Storage::Aliyun::Connection.new(@opts)
  end

  it "should put" do
    url = @connection.put("a/a.jpg",load_file("foo.jpg"))
    Net::HTTP.get_response(URI.parse(url)).code.should == "200"
  end

  it "should put with / prefix" do
    url = @connection.put("/a/a.jpg",load_file("foo.jpg"))
    Net::HTTP.get_response(URI.parse(url)).code.should == "200"
  end
  
  it "should delete" do
    url = @connection.delete("/a/a.jpg")
    Net::HTTP.get_response(URI.parse(url)).code.should == "404"
  end
  
  it "should support custom domain" do
    @opts[:aliyun_host] = "https://foo.bar.com"
    @connection = CarrierWave::Storage::Aliyun::Connection.new(@opts)
    url = @connection.put("a/a.jpg",load_file("foo.jpg"))
    url.should == "https://foo.bar.com/a/a.jpg"
    @opts[:aliyun_host] = "http://foo.bar.com"
    @connection = CarrierWave::Storage::Aliyun::Connection.new(@opts)
    url = @connection.put("a/a.jpg",load_file("foo.jpg"))
    url.should == "http://foo.bar.com/a/a.jpg"
  end
end
