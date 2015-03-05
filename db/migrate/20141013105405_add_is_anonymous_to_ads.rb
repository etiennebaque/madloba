class AddIsAnonymousToAds < ActiveRecord::Migration
  def change
    add_column :ads, :is_anonymous, :boolean
  end
end
