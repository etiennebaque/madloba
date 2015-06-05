class AddAnonuserToAds < ActiveRecord::Migration
  def change
    add_column :ads, :anon_name, :string
    add_column :ads, :anon_email, :string
  end
end
