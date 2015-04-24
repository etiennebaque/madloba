class CreateAdItems < ActiveRecord::Migration
  def change
    create_table :ad_items do |t|
      t.references :ad, index: true
      t.references :item, index: true
      t.boolean :is_quantifiable
      t.integer :quantity

      t.timestamps
    end
  end
end
