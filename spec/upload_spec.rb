require File.dirname(__FILE__) + '/spec_helper'

describe 'Upload' do
  def setup_db
    ActiveRecord::Schema.define(version: 1) do
      create_table :photos do |t|
        t.column :image, :string
        t.column :content_type, :string
      end

      create_table :attachments do |t|
        t.column :file, :string
        t.column :content_type, :string
      end
    end
  end

  def drop_db
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  class PhotoUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    version :small do
      process resize_to_fill: [120, 120]
    end

    def store_dir
      'photos'
    end
  end

  class AttachUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    def store_dir
      'attachs'
    end
  end

  class Photo < ActiveRecord::Base
    mount_uploader :image, PhotoUploader
  end

  class Attachment < ActiveRecord::Base
    mount_uploader :file, AttachUploader
  end

  before :all do
    setup_db
  end

  after :all do
    drop_db
  end

  describe 'Upload Image' do
    context 'should upload image' do
      before(:all) do
        @file = load_file('foo.jpg')
        @file1 = load_file('foo.gif')
        @photo = Photo.new(image: @file)
        @photo1 = Photo.new(image: @file1)
        @photo.save
        @photo1.save
      end

      it 'should upload file' do
        expect(@photo.persisted?).to eq true
        expect(@photo[:image].present?).to eq true
        # FIXME: image? 需要实现
        # expect(@photo.image?).to eq true
      end

      it 'should get uploaded file' do
        img = open(@photo.image.url)
        expect(img.size).to eq @file.size
        expect(img.content_type).to eq 'image/jpeg'

        expect(@photo1.persisted?).to eq true
        img1 = open(@photo1.image.url)
        expect(img1.size).to eq @file1.size
        expect(img1.content_type).to eq 'image/gif'
      end

      it 'sholud get small version uploaded file' do
        expect(open(@photo.image.small.url)).not_to eq nil
        expect(open(@photo1.image.small.url)).not_to eq nil
      end

      it 'should get Aliyun OSS thumb url with :thumb option' do
        url = @photo.image.url(thumb: '?x-oss-process=image/resize,w_100')
        expect(url).to include(ALIYUN_HOST)
        expect(url).to include('?x-oss-process=image/resize,w_100')
        url1 = @photo.image.url(thumb: '?x-oss-process=image/resize,w_60')
        expect(url1).to include(ALIYUN_HOST)
        expect(url1).to include('?x-oss-process=image/resize,w_60')
        img1 = open(url)
        expect(img1.size).not_to eq 0
        expect(img1.content_type).to eq 'image/jpeg'
      end
    end

    context 'should update zip' do
      before(:all) do
        @file = load_file('foo.zip')
        @attachment = Attachment.new(file: @file)
        @attachment.save
      end

      it 'should upload file' do
        expect(@attachment.persisted?).to eq true
      end

      it 'should get uploaded file' do
        attach = open(@attachment.file.url)
        expect(attach.size).to eq @file.size
        expect(attach.content_type).to eq 'application/zip'
        expect(attach.meta['content-disposition']).to eq 'attachment;filename=foo.zip'
      end

      # it 'should delete old file when upload a new file again' do
      #   old_url = @attachment.file.url
      #   puts "------- old_url #{old_url}"
      #   @attachment.file = load_file('foo.gif')
      #   @attachment.save
      #   puts "------- new_url #{@attachment.file.url}"
      #   res = Net::HTTP.get_response(URI.parse(old_url))
      #   expect(res.code).to eq '404'
      # end
    end
  end
end
