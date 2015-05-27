class Ad < ActiveRecord::Base
  has_many :ad_items
  has_many :items, through: :ad_items
  belongs_to :location
  belongs_to :user

  # Ad image
  mount_uploader :image, ImageUploader
  process_in_background :image

  accepts_nested_attributes_for :location
  accepts_nested_attributes_for :ad_items, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :items

  validates :title, :location_id, :user_id, :description, presence: true
  validates :is_giving, inclusion: [true, false]
  validates :is_anonymous, inclusion: [true, false]
  validate :has_items
  validates_size_of :image, maximum: 5.megabytes

  def has_items
    errors.add(:base, I18n.t('ad.error_ad_must_have_item')) if (self.ad_items.blank? || self.ad_items.empty?)
  end

  # The publisher of an ad might not want to have their full name publicly displayed.
  # This method defines whether to show the username or the full name.
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

  # To be used in the map popup, on ads#show page.
  def item_list
    result = []
    self.ad_items.each do |ad_item|
      result << ad_item.item.capitalized_name
    end
    return result.join(', ')
  end

end
