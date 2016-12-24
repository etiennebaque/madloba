class PostItem < ActiveRecord::Base
  belongs_to :post
  belongs_to :item
  accepts_nested_attributes_for :item, :reject_if => :all_blank

end
