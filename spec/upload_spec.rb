require File.dirname(__FILE__) + '/spec_helper'

require "open-uri"
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

describe "Upload" do
  def setup_db
    ActiveRecord::Schema.define(:version => 1) do
      create_table :photos do |t|
        t.column :image, :string
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
      process :resize_to_fill => [120, 120]
    end
    
    def store_dir
      "photos"
    end
  end

  class Photo < ActiveRecord::Base
    mount_uploader :image, PhotoUploader
  end
  
  
  before :all do
    setup_db
  end
  
  after :all do
    drop_db
  end
  
  context "Upload Image" do
    it "should upload image" do
      f = load_file("foo.jpg")
      photo = Photo.create(:image => f)
      photo.errors.count.should == 0
      open(photo.image.url).should_not == nil
      open(photo.image.url).size.should == f.size
      open(photo.image.small.url).should_not == nil
    end
  end
end