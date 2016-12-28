## 0.7.1

- Fix Storage's read. (#41)

## 0.7.0

- 支持设置 Content-Disposition;

## 0.6.0

- 调整，优化类结构:
  - `CarrierWave::Storage::Aliyun::Connection` -> `CarrierWave::Aliyun::Bucket`
  - `CarrierWave::Storage::Aliyun::File` -> `CarrierWave::Storage::AliyunFile`

## 0.5.1

- 修正 Aliyun 内部网络上传的支持；(#36)

## 0.5.0

- 增加 Aliyun OSS 图片处理参数的支持，允许 url 传入 `:thumb` 以生成缩略图 URL；
- 配置项增加 `config.aliyun_img_host`。

## 0.4.4

- 修正对 Carrierwave master 版本的支持，它们[移除了](https://github.com/carrierwaveuploader/carrierwave/pull/1813) `carrierwave/processing/mime_types`；

## 0.4.3

- 修正私密空间下载地址算法的问题，导致偶尔会签名错误无法下载的问题；

## 0.4.2

- `config.aliyun_host` 现在支持配置 //you-host.com，以便同时支持 http 和 https。

## 0.4.1

- 由于 aliyun-oss-sdk 目前不支持 internal 上传，暂时去掉，以免签名错误。

## 0.4.0

- 采用 aliyun-oss-sdk 来作为上传后端，不再依赖 rest-client，不再内部实现上传逻辑；
- 增加 `config.aliyun_private_read` 配置项，开启以后，返回的 @user.avatar.url 将会是带 Token 和有效期的 URL，可以用于访问私有读取空间的文件；
- 去掉 `config.aliyun_upload_host` 配置项，删除了阿里内部的支持，以后请用 0.3.x 版本；

## 0.3.6

- 修正上传中文文件名无法成功的问题；

## 0.3.5

- CarrierWave::Storage::Aliyun::File 继承 CarrierWave::SanitizedFile 以实现一些方法；

## 0.3.4

- Use OpenSSL::HMAC with Ruby 2.2.0.

## 0.3.3

- 增加 `config.aliyun_upload_host`, 以便有需要的时候，可以自由修改上传的 host.

## 0.3.2

- 请注意 `config.aliyun_host` 要求修改带 HTTP 协议，以便支持设置 http:// 或 https://.

## 0.3.1

- 修复当文件名中包含了 "+"，在 OSS 中上传会遇到签名不对应的问题；

## 0.3.0

- 新增 `aliyun_area` 参数，用于配置 OSS 所在地区数据中心；

## 0.2.1

- 避免计算上传文件的时候读取所有内容到内存，之前的做法对于大文件会耗费过多的内存；
- Carrierwave::Storage::Aliyum::Connection 的 put 方法接口变化，file 现在应该传一个 File 的实例。

## 0.2.0

- Aliyun OSS 新的[三级域名规则支持](http://bbs.aliyun.com/read.php?tid=139226) by [chaixl](https://github.com/chaixl)
- 注意! 如果你之前使用 0.1.5 一下的版本，你可能需要调整一下你的自定义域名的 CNAME 解析，阿里云新的 URL 结构变化(少了 Bucket 一层目录)，当然你也可以选择不要升级，之前 0.1.5 版本是稳定的。

## 0.1.5

- 自定义域名支持

## 0.1.3

- delete 接口加入。
- 支持 Carriewave 自动在更新上传文件的时候删除老文件（比如，用户重新上传头像，老头像图片文件将会被 CarrierWave 删除）。

## 0.1.2

- 修正 content_type 的支持，自动用原始文件的 content_type，以免上传 zip 之类的文件以后无法下载.

## 0.1.1

- 修改 Aliyun OSS 的请求地址.
- 加入可选项，使用 Aliyun 内部地址调用上传，以提高内部网络使用的速度.

## 0.1.0

- 功能实现.
