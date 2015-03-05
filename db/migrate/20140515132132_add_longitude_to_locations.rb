class AddLongitudeToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :longitude, :decimal, precision: 8, scale: 5
  end
end
