class RenameIsAnonymousInAds < ActiveRecord::Migration
  def change
    rename_column :ads, :is_anonymous, :is_username_used
  end
end
