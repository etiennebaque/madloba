class AddDistrictRefToLocations < ActiveRecord::Migration
  def change
    add_reference :locations, :district, index: true
  end
end
