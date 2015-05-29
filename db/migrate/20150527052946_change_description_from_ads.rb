class ChangeDescriptionFromAds < ActiveRecord::Migration
  def change
    change_column :ads, :description, :text
  end
end
