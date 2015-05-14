class ChangeQuantityInAdItems < ActiveRecord::Migration
  def change
    change_column :ad_items, :quantity, :string
  end
end
