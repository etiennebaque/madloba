class AddBoundsToDistricts < ActiveRecord::Migration
  def change
    add_column :districts, :bounds, :jsonb
  end
end
