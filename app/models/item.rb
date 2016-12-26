class Item < ActiveRecord::Base
  has_many :post_items
  has_many :posts, through: :post_items, dependent: :destroy

  validates :name, presence: true

  before_save { |item| item.name.downcase! }

  def capitalized_name
    self.name.nil? ? '' : self.name.capitalize
  end

end
