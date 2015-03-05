class AddStreetNumberToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :street_number, :string
  end
end
