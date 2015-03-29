class Ad < ActiveRecord::Base
  belongs_to :item
  belongs_to :location
  belongs_to :user

  # Ad image
  mount_uploader :image, ImageUploader
  process_in_background :image

  accepts_nested_attributes_for :location

  validates :title, :number_of_items, :location_id, :item_id, :user_id, :description, presence: true
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

end
