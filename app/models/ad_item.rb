class AdItem < ActiveRecord::Base
  belongs_to :ad
  belongs_to :item
  accepts_nested_attributes_for :item
end
