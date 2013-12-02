## 0.3.0

* 新增 `aliyun_area` 参数，用于配置 OSS 所在地区数据中心；

## 0.2.1

* 避免计算上传文件的时候读取所有内容到内存，之前的做法对于大文件会耗费过多的内存；
* Carrierwave::Storage::Aliyum::Connection 的 put 方法接口变化，file 现在应该传一个 File 的实例。

## 0.2.0

* Aliyun OSS 新的[三级域名规则支持](http://bbs.aliyun.com/read.php?tid=139226) by [chaixl](https://github.com/chaixl)
* 注意! 如果你之前使用 0.1.5 一下的版本，你可能需要调整一下你的自定义域名的 CNAME 解析，阿里云新的 URL 结构变化(少了 Bucket 一层目录)，当然你也可以选择不要升级，之前 0.1.5 版本是稳定的。

## 0.1.5

* 自定义域名支持

## 0.1.3

* delete 接口加入。
* 支持 Carriewave 自动在更新上传文件的时候删除老文件（比如，用户重新上传头像，老头像图片文件将会被 CarrierWave 删除）。

## 0.1.2

* 修正 content_type 的支持，自动用原始文件的 content_type，以免上传 zip 之类的文件以后无法下载.

## 0.1.1

* 修改 Aliyun OSS 的请求地址.
* 加入可选项，使用 Aliyun 内部地址调用上传，以提高内部网络使用的速度.

## 0.1.0

* 功能实现.