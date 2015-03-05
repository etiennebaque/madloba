class Item < ActiveRecord::Base
  belongs_to :category
  has_many :ads, dependent: :destroy

  validates :name, :category, presence: true

end
