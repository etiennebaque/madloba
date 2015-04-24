class Item < ActiveRecord::Base
  belongs_to :category
  has_many :ad_items
  has_many :ads, through: :ad_items, dependent: :destroy

  validates :name, :category, presence: true

end
