class AddExpireDateToAds < ActiveRecord::Migration
  def change
    add_column :ads, :expire_date, :date
  end
end
