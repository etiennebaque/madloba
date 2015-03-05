class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.string :name
      t.decimal :latitude, precision: 7, scale: 5
      t.decimal :longitude, precision: 8, scale: 5

      t.timestamps
    end
  end
end
