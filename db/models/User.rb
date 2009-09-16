require 'paperclip'
class User < ActiveRecord::Base
  has_many :friendships
  has_many :firends, :through => :friendships

  has_attached_file :picture,
    :styles => { :thumb => "120x120", :medium => "550x550" }


  validates_presence_of :firstname, :lastname, :email
  validates_uniqueness_of :email
  validates_attachment_size :picture, 
    :less_than => 5.megabytes, 
    :message => "File has to be less then 5Mb"
  validates_attachment_content_type :picture, 
    :content_type => ["image/jpg", "image/png", "image/jpeg"],
    :message => "Not a valid file type"
end
