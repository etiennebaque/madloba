class AddTypeToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :type, :string, after: :id
  end
end
