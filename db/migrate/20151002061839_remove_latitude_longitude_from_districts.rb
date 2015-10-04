class RemoveLatitudeLongitudeFromDistricts < ActiveRecord::Migration
  def change
    remove_column :districts, :longitude, :decimal
    remove_column :districts, :latitude, :decimal
  end
end
