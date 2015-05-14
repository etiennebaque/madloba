class AdItem < ActiveRecord::Base
  belongs_to :ad
  belongs_to :item
  accepts_nested_attributes_for :item

  validates :item_id, :ad_id, :quantity, presence: true

end
