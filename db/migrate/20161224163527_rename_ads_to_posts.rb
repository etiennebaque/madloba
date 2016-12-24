class RenameAdsToPosts < ActiveRecord::Migration
  def change
    rename_table :ads, :posts
  end
end
