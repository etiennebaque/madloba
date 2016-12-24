class RenameAdItemsToPostItems < ActiveRecord::Migration
  def change
    rename_table :ad_items, :post_items
    rename_column :post_items, :ad_id, :post_id
  end
end
