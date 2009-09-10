class User < ActiveRecord::Base

  has_attached_file :picture,
    :styles => { :thumb => "120x120", :medium => "550x550" }

  validates_presence_of :firstname, :lastname, :email
  validates_uniqueness_of :email
end
