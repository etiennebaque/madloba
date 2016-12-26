class RemoveCategoryFromItems < ActiveRecord::Migration
  def change
    remove_reference :items, :category
  end
end
