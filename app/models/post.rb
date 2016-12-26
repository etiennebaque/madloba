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

  validates_presence_of :title, :description
  validates :giving, inclusion: [true, false]
  validates :username_used, inclusion: [true, false]
  validate :has_items
  validate :has_anon_name_and_email
  validates_size_of :image, maximum: 5.megabytes

  apply_simple_captcha

  # This method returns the right query to display relevant markers, on the home page.
  def self.search(cat_nav_state, searched_item, selected_item_ids, user_action, post_id)

    if post_id.present?
      # Search by post ids when adding posts on home page dynamically, when other user just created a post (websocket)
      posts = Post.find(post_id)
    else
      posts = Post.select(:marker_info).where("expire_date >= ? and (marker_info->>'post_id') is not null", Date.today)

      if cat_nav_state || searched_item
        if cat_nav_state
          puts cat_nav_state
          if searched_item
            # We search for posts in relation to the searched item and the current category navigation state.
            posts = posts.joins(:items).where(items: {category_id: cat_nav_state, id: selected_item_ids})
          else
            # We search for posts in relation to our current category navigation state.
            posts = posts.joins(:items).where(items: {category_id: cat_nav_state})
          end
        elsif searched_item
          posts = posts.joins(:items).where(items: {id: selected_item_ids})
        end
      end

      if user_action
        # If the user is searching for items, we need to show the posted posts, which people give stuff away.
        posts = posts.where("posts.giving = ?", user_action == 'searching')
      end

    end

    posts = posts.pluck(:marker_info).uniq

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
    if self.is_anonymous
      self.anon_email
    else
      self.user.email
    end
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
    self.items.map{|i| i.try(:capitalize)}.compact.join(', ')
  end

  # {
  #   lat: 12.23456,
  #   lng: 12.23456,
  #   post_id: 123,
  #   category_id: 2
  #   icon: 'fa-circle',
  #   color: 'blue',
  # }
  def serialize!
    location = self.location
    cat = self.category
    info = {lat: location.latitude, lng: location.longitude, post_id: self.id}
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
