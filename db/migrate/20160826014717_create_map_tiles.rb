class CreateMapTiles < ActiveRecord::Migration
  def change
    create_table :map_tiles do |t|
      t.string :name
      t.string :tile_url
      t.string :attribution
      t.string :api_key
      t.string :map_name

      t.timestamps null: false
    end
  end
end
