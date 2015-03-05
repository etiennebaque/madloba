class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.string :address
      t.string :postal_code
      t.string :province
      t.string :city
      t.string :phone_number
      t.string :website
      t.text :description

      t.timestamps
    end
  end
end
