class AddBoundsToDistricts < ActiveRecord::Migration
  def change
    add_column :districts, :bounds, :text
  end
end
