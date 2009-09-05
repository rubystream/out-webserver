class Init < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :firstname, :null => false
      t.string :lastname, :null => false
      t.string :email, :null => false
      t.boolean :admin, :default => false
    end
  end

  def self.down
    drop_table :users
  end
end
