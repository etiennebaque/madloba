class AddMarkerInfoToAds < ActiveRecord::Migration
  def change
    add_column :ads, :marker_info, :jsonb, default: '{}'
  end
end
