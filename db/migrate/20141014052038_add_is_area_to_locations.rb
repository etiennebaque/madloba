class AddIsAreaToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :is_area, :boolean
  end
end
