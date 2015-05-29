class CreateAdItems < ActiveRecord::Migration
  def change
    create_table :ad_items do |t|
      t.references :ad, index: true
      t.references :item, index: true

      t.timestamps
    end
  end
end
