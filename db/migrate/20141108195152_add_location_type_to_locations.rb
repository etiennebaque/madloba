class AddLocationTypeToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :loc_type, :string
  end
end
