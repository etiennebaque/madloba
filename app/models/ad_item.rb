class AdItem < ActiveRecord::Base
  belongs_to :ad
  belongs_to :item
end
