class ChangeColumnsInAreas < ActiveRecord::Migration
  def change
    remove_column :areas, :bounds, :text
    add_column :areas, :latitude, :decimal, precision: 8, scale: 5
    add_column :areas, :longitude, :decimal, precision: 8, scale: 5
  end
end
