class Location < ActiveRecord::Base
  has_many :ads, dependent: :destroy
  belongs_to :user
  belongs_to :area

  validates_presence_of :latitude, :longitude
  # 'Postal code' field is not necessary only if user chooses an area name instead.
  validates_presence_of :postal_code, if: lambda { self.area == nil}
  validates :latitude , numericality: { greater_than:  -90, less_than:  90 }
  validates :longitude, numericality: { greater_than: -180, less_than: 180 }

  #scope :type, -> (location_type) { where('ads.expire_date >= ? AND loc_type = ?', Date.today, location_type)}

  attr_accessor :country

  # This method returns the right query to display relevant markers, on the home page.
  def self.search(location_type, cat_nav_state, searched_item, selected_item_ids, user_action)

    #locations = Location.includes(ads: {items: :category}).type(location_type).references(:ads)
    if cat_nav_state || searched_item

      locations = Location.includes(ads: {items: :category}).where('ads.expire_date >= ?', Date.today).references(:ads)

      if cat_nav_state
        if searched_item
          # We search for ads in relation to the searched item and the current category navigation state.
          locations = locations.where(items: {category_id: cat_nav_state, id: selected_item_ids})
        else
          # We search for ads in relation to our current category navigation state.
          locations = locations.where(items: {category_id: cat_nav_state})
        end
      elsif searched_item
        locations = locations.where(items: {id: selected_item_ids})
      end

    else
      locations = Location.includes(:ads).where('ads.expire_date >= ?', Date.today).references(:ads)
    end

    if user_action
      # If the user is searching for items, we need to show the posted ads, which people give stuff away.
      locations = locations.where("ads.giving = ?", user_action == 'searching')
    end

    if location_type == 'area'
      locations = locations.group_by(&:area_id)
    end

    return locations
  end

  def area?
    address.blank? && postal_code.blank? && street_number.blank?
  end

  # This method creates the final longitudes and latitudes for each area to be displayed on the map.
  def self.define_area_geocodes (locations_area)
    area_geocodes = {}

    if (locations_area && locations_area.length > 0)
      areas = Area.where(id: locations_area.keys)
      areas.each do |area|
        area_geocodes[area.id] = {'name' => area.name, 'bounds' => area.bounds}
      end
    end

    return area_geocodes
  end

  def marker_message
    full_name
  end

  def full_name
    name.present? ? name : full_address
  end

  def full_address
    a = name.present? ? [name, '-'] : []
    if area?
      a << area.name
    else
      a << street_number if street_number.present?
      a << "#{address}, #{postal_code}"
    end
    a.join(' ')
  end

  def full_website_url
    website.include?('http') ? website : "http://#{self.website}"
  end

  def clickable_map_for_edit
    CLICKABLE_MAP_EXACT_MARKER
  end

  def address_geocode_lookup(short: false)
    location_info = short ? [self.address] : [self.full_address, self.postal_code]
    this_city = self.city.nil? ? Rails.cache.fetch(CACHE_CITY_NAME) {Setting.find_by_key(:city).value} : self.city
    this_country = self.country.nil? ? Rails.cache.fetch(CACHE_COUNTRY_NAME) {Setting.find_by_key(:country).value} : self.country
    location_info += [this_city, self.province, this_country]
    location_info.reject{|e| e.to_s.empty?}.join(',')
  end

end