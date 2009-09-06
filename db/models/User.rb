class User < ActiveRecord::Base

  validates_presence_of :firstname, :lastname, :email
  validates_uniqueness_of :email
end
