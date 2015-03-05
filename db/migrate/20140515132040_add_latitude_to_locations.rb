class AddLatitudeToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :latitude, :decimal, precision: 7, scale: 5
  end
end
