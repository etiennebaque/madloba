class RemoveNumberOfItemsFromAds < ActiveRecord::Migration
  def change
    remove_column :ads, :number_of_items, :integer
  end
end
