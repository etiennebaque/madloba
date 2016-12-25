class Location < ActiveRecord::Base
  has_many :posts, dependent: :destroy
  belongs_to :user
  belongs_to :area

  validates_presence_of :latitude, :longitude

  validate :location_fields_cannot_be_blank
  validates :latitude , numericality: { greater_than:  -90, less_than:  90 }
  validates :longitude, numericality: { greater_than: -180, less_than: 180 }

  #scope :type, -> (location_type) { where('posts.expire_date >= ? AND loc_type = ?', Date.today, location_type)}

  attr_accessor :country

  EXACT_ADDRESS_ICON = 'fa-home'
  AREA_ADDRESS_ICON = 'fa-dot-circle-o'

  # This method returns the right query to display relevant markers, on the home page.
  def self.search(location_type, cat_nav_state, searched_item, selected_item_ids, user_action)

    #locations = Location.includes(posts: {items: :category}).type(location_type).references(:posts)
    if cat_nav_state || searched_item

      locations = Location.includes(posts: {items: :category}).where('posts.expire_date >= ?', Date.today).references(:posts)

      if cat_nav_state
        if searched_item
          # We search for posts in relation to the searched item and the current category navigation state.
          locations = locations.where(items: {category_id: cat_nav_state, id: selected_item_ids})
        else
          # We search for posts in relation to our current category navigation state.
          locations = locations.where(items: {category_id: cat_nav_state})
        end
      elsif searched_item
        locations = locations.where(items: {id: selected_item_ids})
      end

    else
      locations = Location.includes(:posts).where('posts.expire_date >= ?', Date.today).references(:posts)
    end

    if user_action
      # If the user is searching for items, we need to show the posted posts, which people give stuff away.
      locations = locations.where("posts.giving = ?", user_action == 'searching')
    end

    if location_type == 'area'
      locations = locations.group_by(&:area_id)
    end

    return locations
  end

  def area?
    area.present? && (address.blank? || postal_code.blank?)
  end

  # This method creates the final longitudes and latitudes for each area to be displayed on the map.
  def self.define_area_geocodes
    area_geocodes = {}
    Area.all.each do |area|
      area_geocodes[area.id] = {name: area.name, latitude: area.latitude, longitude: area.longitude}
    end
    area_geocodes
  end

  def marker_message
    full_name
  end

  def full_name
    name.present? ? name : full_address
  end

  def full_address
    return area.name if area?

    a = name.present? ? [name, '-'] : []
    a << street_number if street_number.present?
    a << "#{address}, #{postal_code}" if address.present? && postal_code.present?
    a.join(' ')
  end

  def full_website_url
    website.include?('http') ? website : "http://#{self.website}"
  end

  def location_fields_cannot_be_blank
    conditions_met = address.present? || area.present?
    if !conditions_met
      msg = Area.any? ? I18n.t('location.error_location_fields') : I18n.t('location.error_location_address_only')
      errors.add(:base, msg)
    end
  end

  def address_geocode_lookup(short: false)
    location_info = short ? [self.address] : [self.full_address, self.postal_code]
    this_city = self.city.nil? ? Rails.cache.fetch(CACHE_CITY_NAME) {Setting.find_by_key(:city).value} : self.city
    this_country = self.country.nil? ? Rails.cache.fetch(CACHE_COUNTRY_NAME) {Setting.find_by_key(:country).value} : self.country
    location_info += [this_city, self.province, this_country]
    location_info.reject{|e| e.nil? || e.blank?}.join(',')
  end

end