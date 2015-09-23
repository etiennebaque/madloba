class AddBoundsToDistricts < ActiveRecord::Migration
  def change
    add_column :districts, :bounds, :json
  end
end
