class CreateAds < ActiveRecord::Migration
  def change
    create_table :ads do |t|
      t.string :title
      t.string :description
      t.integer :number_of_items
      t.references :item, index: true
      t.references :location, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
