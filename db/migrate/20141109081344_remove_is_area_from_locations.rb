class RemoveIsAreaFromLocations < ActiveRecord::Migration
  def change
    remove_column :locations, :is_area, :boolean
  end
end
