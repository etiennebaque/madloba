class RenameDistrictsToAreas < ActiveRecord::Migration
  def change
    rename_table :districts, :areas
  end
end
