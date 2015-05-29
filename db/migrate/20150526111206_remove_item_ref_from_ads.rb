class RemoveItemRefFromAds < ActiveRecord::Migration
  def change
    remove_reference :ads, :item, index: true
  end
end
