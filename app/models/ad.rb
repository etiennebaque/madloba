class Ad < ActiveRecord::Base
  has_many :ad_items
  has_many :items, through: :ad_items
  belongs_to :location
  belongs_to :user

  # Ad image
  mount_uploader :image, ImageUploader
  process_in_background :image

  accepts_nested_attributes_for :location

  validates :title, :location_id, :user_id, :description, presence: true
  validates :is_giving, inclusion: [true, false]
  validates :is_anonymous, inclusion: [true, false]
  validates_size_of :image, maximum: 5.megabytes

  def username_to_display
    if (self.is_anonymous)
      self.user.username
    else
      "#{self.user.first_name} #{self.user.last_name}"
    end
  end

  def has_expired
    self.expire_date < Date.today
  end

  def thumb_image_url
    self.image_url(:thumb)
  end

  def recreate_delayed_versions!
    self.image.is_processing_delayed = true
    self.image.recreate_versions!
  end

  def item_list
    result = []
    self.ad_items.each do |ad_item|
      result << "#{ad_item.item.name} (#{ad_item.quantity})"
    end
    return result.join(', ')
  end

end
