class RenameVariousColumns < ActiveRecord::Migration
  def change
    rename_column :ads, :is_username_used, :username_used
    rename_column :ads, :is_giving, :giving
    rename_column :locations, :district_id, :area_id
  end
end
