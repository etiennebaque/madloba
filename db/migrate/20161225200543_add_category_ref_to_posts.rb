class AddCategoryRefToPosts < ActiveRecord::Migration
  def change
    add_reference :posts, :category, index: true
    remove_reference :items, :category
  end
end
