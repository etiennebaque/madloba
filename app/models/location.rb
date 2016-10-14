class Location < ActiveRecord::Base
  has_many :ads, dependent: :destroy
  belongs_to :user
  belongs_to :district

  validates_presence_of :address, :postal_code, if: lambda { self.exact? }
  validates_presence_of :latitude, :longitude
  # 'Postal code' field is not necessary only if user chooses a district name instead.
  validates_presence_of :postal_code, if: lambda { self.district == nil}
  validates :latitude , numericality: { greater_than:  -90, less_than:  90 }
  validates :longitude, numericality: { greater_than: -180, less_than: 180 }

  scope :type, -> (location_type) { where('ads.expire_date >= ? AND loc_type = ?', Date.today, location_type)}

  attr_accessor :country

  # This method returns the right query to display relevant markers, on the home page.
  def self.search(location_type, cat_nav_state, searched_item, selected_item_ids, user_action, ad_id)

    locations = Location.includes(ads: {items: :category}).type(location_type).references(:ads)

    if ad_id.present?
      # Search by ad ids when adding ads on home page dynamically, when other user just created an ad (websocket)
      locations = locations.where('ads.id = ?', ad_id)
    end

    if cat_nav_state || searched_item
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
    end

    if user_action
      # If the user is searching for items, we need to show the posted ads, which people give stuff away.
      locations = locations.where("ads.is_giving = ?", user_action == 'searching')
    end

    if location_type == 'postal'
      locations = locations.group_by(&:area)
    elsif location_type == 'district'
      locations = locations.group_by(&:district_id)
    end

    return locations
  end


  # This method creates the final longitudes and latitudes for each area to be displayed on the map.
  def self.define_area_geocodes (locations_postal, locations_district)
    area_geocodes = {}
    if (locations_postal && locations_postal.length > 0)
      locations_postal.each do |area, locations|
        total_latitude = 0.0
        total_longitude = 0.0
        count = 0
        locations.each do |location|
          total_latitude += location.latitude.to_f
          total_longitude += location.longitude.to_f
          count += 1
        end
        area_geocodes[area] = {'latitude' => total_latitude / count, 'longitude' => total_longitude / count}
      end
    end

    if (locations_district && locations_district.length > 0)
      districts = District.where(id: locations_district.keys)
      districts.each do |district|
        area_geocodes[district.id] = {'name' => district.name, 'bounds' => district.bounds}
      end
    end

    return area_geocodes
  end

  def area?
    false
  end

  def district?
    false
  end

  def postal?
    false
  end

  def exact?
    false
  end

  def area
    area_length = Setting.find_by_key(:area_length).value.to_i
    self.postal_code[0..area_length-1]
  end

  def marker_message
  end

  def full_name
    name.present? ? name : full_address
  end

  def full_address
    a = []
    a << street_number if street_number.present?
    a << address
    a.join(' ')
  end

  def name_and_or_full_address
    name.present? ? "#{name} - #{location_type_address_public}" : location_type_address_public
  end

  # if the location has no name, return "unnamed location"
  def location_full_name
    name.present? ? name : "(#{I18n.t('admin.location.unnamed')})"
  end

  def location_type_address
  end

  # On the ads/show page, we're not necessarily showing the full address,
  # depending of how the location type.
  def location_type_address_public
  end

  def full_website_url
    website.include?('http') ? website : "http://#{self.website}"
  end

  def clickable_map_for_edit
    area? ? CLICKABLE_MAP_AREA_MARKER : CLICKABLE_MAP_EXACT_MARKER
  end

  def address_geocode_lookup(short: false)
    location_info = short ? [self.address] : [self.full_address, self.postal_code]
    this_city = self.city.nil? ? Rails.cache.fetch(CACHE_CITY_NAME) {Setting.find_by_key(:city).value} : self.city
    this_country = self.country.nil? ? Rails.cache.fetch(CACHE_COUNTRY_NAME) {Setting.find_by_key(:country).value} : self.country
    location_info += [this_city, self.province, this_country]
    location_info.reject{|e| e.to_s.empty?}.join(',')
  end

  def define_subclass
    self.type = "Locations::#{self.loc_type.capitalize}Location"
    self.save
  end

end