class Post < ActiveRecord::Base
  has_many :post_items
  has_many :items, through: :post_items
  belongs_to :category
  belongs_to :location
  belongs_to :user

  include ApplicationHelper
  after_initialize :default_values

  # Post image
  mount_uploader :image, ImageUploader
  process_in_background :image

  accepts_nested_attributes_for :location, :reject_if => :all_blank
  accepts_nested_attributes_for :post_items, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :items

  validates_presence_of :title, :description, :category
  validates :giving, inclusion: [true, false]
  validates :username_used, inclusion: [true, false]
  validate :has_items
  validate :has_anon_name_and_email
  validates_size_of :image, maximum: 5.megabytes

  apply_simple_captcha

  # This method returns the right query to display relevant markers, on the home page.
  def self.search(params, selected_item_ids, post_id)
    return Post.find(post_id) if post_id.present?

    user_action = params[:q]
    searched_item = params[:item]
    cat_nav_state = params[:cat].present? ? params[:cat].split(" ") : []

    posts = Post.where("expire_date >= ? and (marker_info->>'post_id') is not null", Date.today).uniq

    posts = posts.joins(:items).where(items: {id: selected_item_ids}) if searched_item.present?
    posts = posts.where(category_id: cat_nav_state) if cat_nav_state.present?
    posts = posts.where(giving: user_action == 'searching') if user_action.present?

    posts
  end

  # method used to save the posts#new form. A captcha is required when the user is anonymous.
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
    errors.add(:base, I18n.t('post.error_post_must_have_item')) if (self.post_items.blank? || self.post_items.empty?)
  end

  def has_anon_name_and_email
    errors.add(:base, I18n.t('post.provide_anon_name')) if (self.user_id.nil? && self.anon_name.blank?)
    errors.add(:base, I18n.t('post.provide_anon_email')) if (self.user_id.nil? && self.anon_email.blank?)
  end

  def action
    giving? ? I18n.t('admin.post.giving_away') : I18n.t('admin.post.accepting')
  end

  def action_item
    act = giving? ? I18n.t('admin.post.giving_away') : I18n.t('admin.post.accepting')
    self.items.each do |item|

    end

    "#{act} #{self.items.map(&:name).join(', ')}"
  end

  # The publisher of a post might not want to have their full name publicly displayed.
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

  # If we deal with an anonymous post publisher, we get the email from the post itself (no user model created)
  # Otherwise we get the email from the user model linked to the post.
  def email_to_display
    is_anonymous ? anon_email : user.email
  end

  def short_description
    description.length > 100 ? "#{description[0..96]}..." : description
  end


  def has_expired
    self.expire_date < Date.today
  end

  # Define whether or not this post has been created by a signed-in or an anonymous user.
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

  # Clean list of items linked to a post
  def item_list
    self.items.map{|i| i.name}.compact.join(', ')
  end

  # {
  #   lat: 12.23456,
  #   lng: 12.23456,
  #   area: 1
  #   post_id: 123,
  #   category_id: 2
  #   icon: 'fa-circle',
  #   color: 'blue',
  # }
  def serialize!
    location = self.location
    cat = self.category
    info = {
        lat: location.latitude,
        lng: location.longitude,
        area: location.area? ? location.area.id : 0,
        post_id: self.id
    }
    info.merge!({icon: cat.icon, color: cat.marker_color, category_id: cat.id})
    self.marker_info = info
    self.save
  end

  private

  # Setting default values after initialization.
  def default_values
    # we define the date when the post won't be published any longer (see maximum number of days, in Settings table)
    if max_number_days_publish == '0'
      # No limit set for post expiration. Let's use 2100-01-01 as a default date value
      self.expire_date = Date.new(2100,1,1)
    else
      d = Date.today
      self.expire_date = d + max_number_days_publish.to_i
    end
  end

end
