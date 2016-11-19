class Ad < ActiveRecord::Base
  has_many :ad_items
  has_many :items, through: :ad_items
  belongs_to :location
  belongs_to :user

  include ApplicationHelper
  after_initialize :default_values

  # Ad image
  mount_uploader :image, ImageUploader
  process_in_background :image

  accepts_nested_attributes_for :location, :reject_if => :all_blank
  accepts_nested_attributes_for :ad_items, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :items

  validates_presence_of :title, :description
  validates :giving, inclusion: [true, false]
  validates :username_used, inclusion: [true, false]
  validate :has_items
  validate :has_anon_name_and_email
  validates_size_of :image, maximum: 5.megabytes

  apply_simple_captcha

  # This method returns the right query to display relevant markers, on the home page.
  def self.search(cat_nav_state, searched_item, selected_item_ids, user_action, ad_id)

    if ad_id.present?
      # Search by ad ids when adding ads on home page dynamically, when other user just created an ad (websocket)
      ads = Ad.find(ad_id)
    else
      ads = Ad.select(:marker_info).where("expire_date >= ? and (marker_info->>'ad_id') is not null", Date.today)

      if cat_nav_state || searched_item
        if cat_nav_state
          if searched_item
            # We search for ads in relation to the searched item and the current category navigation state.
            ads = ads.joins(:items).where(items: {category_id: cat_nav_state, id: selected_item_ids})
          else
            # We search for ads in relation to our current category navigation state.
            ads = ads.joins(:items).where(items: {category_id: cat_nav_state})
          end
        elsif searched_item
          ads = ads.joins(:items).where(items: {id: selected_item_ids})
        end
      end

      if user_action
        # If the user is searching for items, we need to show the posted ads, which people give stuff away.
        ads = ads.where("ads.giving = ?", user_action == 'searching')
      end

    end

    ads = ads.pluck(:marker_info)

    ads

  end

  # method used to save the ads#new form. A captcha is required when the user is anonymous.
  # In that case the save method is different than the classic one.
  def save_with_or_without_captcha(current_user)
    if current_user
      self.save
    else
      self.username_used = false
      self.save_with_captcha
    end
  end

  def has_items
    errors.add(:base, I18n.t('ad.error_ad_must_have_item')) if (self.ad_items.blank? || self.ad_items.empty?)
  end

  def has_anon_name_and_email
    errors.add(:base, I18n.t('ad.provide_anon_name')) if (self.user_id.nil? && self.anon_name.blank?)
    errors.add(:base, I18n.t('ad.provide_anon_email')) if (self.user_id.nil? && self.anon_email.blank?)
  end

  def action
    giving? ? I18n.t('admin.ad.giving_away') : I18n.t('admin.ad.accepting')
  end

  def action_item
    act = giving? ? I18n.t('admin.ad.giving_away') : I18n.t('admin.ad.accepting')
    self.items.each do |item|

    end

    "#{act} #{self.items.map(&:name).join(', ')}"
  end

  # The publisher of an ad might not want to have their full name publicly displayed.
  # This method defines whether to show the username or the full name (whether it is anonymous or registered user)
  def username_to_display
    if self.is_anonymous
      self.anon_name
    elsif self.username_used?
      self.user.username
    else
      "#{self.user.first_name} #{self.user.last_name}"
    end
  end

  # If we deal with an anonymous ad publisher, we get the email from the ad itself (no user model created)
  # Otherwise we get the email from the user model linked to the ad.
  def email_to_display
    if self.is_anonymous
      self.anon_email
    else
      self.user.email
    end
  end

  def has_expired
    self.expire_date < Date.today
  end

  # Define whether or not this ad has been created by a signed-in or an anonymous user.
  def is_anonymous
    self.user_id == nil && self.anon_name != nil
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

  private

  # Setting default values after initialization.
  def default_values
    # we define the date when the ad won't be published any longer (see maximum number of days, in Settings table)
    if max_number_days_publish == '0'
      # No limit set for ad expiration. Let's use 2100-01-01 as a default date value
      self.expire_date = Date.new(2100,1,1)
    else
      d = Date.today
      self.expire_date = d + max_number_days_publish.to_i
    end
  end

end
