class AddIsGivingToAds < ActiveRecord::Migration
  def change
    add_column :ads, :is_giving, :boolean
  end
end
