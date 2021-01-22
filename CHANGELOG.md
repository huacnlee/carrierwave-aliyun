## 1.2.3

- 将 Aliyun::OSS 原本的异常原样抛出；
- 验证对 [传输加速](https://help.aliyun.com/document_detail/131312.html) 的能力，并增加文档说明（实际上之前的版本就支持）。

## 1.2.2

- 修正 #79 某些场景中文文件名无法正确上传的问题；
- 修正 #70 上传文件以后 tmp 目录依然还残留着 cache 文件的问题；

## 1.2.1

- 实现 `size` 方法，修正更新图片数组时，新上传的图片会取代旧图片的问题。(#73)

## 1.2.0

- 整理修复 OSS 文件访问 URL 的生成方式，去掉 img host，保持和最新 OSS API 一样的逻辑。
- 生成 URL 的时候，不再强制替换为 https，保持 `aliyun_host` 的配置；

## 1.1.2

- 修正 aliyun-sdk 0.7.0 以上 Thumb URL 生成的支持；
- Requirement aliyun-sdk >= 0.7.0;

## 1.1.2

- 修正废弃调用方式，避免在 Ruby 2.7 里面出现 warning.

## 1.1.1

- 对于 CarrierWave 的 cache 机制正确支持；

## 1.1.0

- 支持 CarrierWave 2.0;

## 1.0.0

- 采用 Aliyun 官方的 SDK 来访问 OSS；
- DEPRECATION: 配置参数命名规范化，老的配置方式将会在 1.1.0 版本废弃，请注意替换：
  - `aliyun_access_id` -> `aliyun_access_key_id`
  - `aliyun_access_key` -> `aliyun_access_key_secret`
  - `aliyun_area` -> `aliyun_region`
  - `aliyun_private_read` -> `aliyun_mode = :private`
- 改进文件上传，支持 `chunk` 模式上传，提升大文件上传的效率以及降低内存开销；

## 0.9.0

- 修正 `AliyunFile#read` 方法会报错的问题。(#53)

## 0.8.1

- 去掉 `aliyun_img_host` 的配置项，不再需要了，Aliyun OSS 的 Bucket 域名以及默认执行图片处理协议，详见：[图片处理指南](https://help.aliyun.com/document_detail/44688.html).
- 在用户未设置 `aliyun_host` 的时候，默认返回 https 协议的 aliyun 主机地址。(#42)

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
