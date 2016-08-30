module ApplicationHelper


  def site_name
    Rails.cache.fetch(CACHE_APP_NAME) {Setting.find_by_key(:app_name).value}
  end

  def site_city
    Rails.cache.fetch(CACHE_CITY_NAME) {Setting.find_by_key(:city).value}
  end

  # Maximum number of days an ad can be published for.
  def max_number_days_publish
    Rails.cache.fetch(CACHE_MAX_DAYS_EXPIRE) {Setting.find_by_key(:ad_max_expire).value}
  end

  # Regardless of what the current navigation state is, we need store all the item names into an array, in order to make the type-ahead of the item search bar work.
  def all_ads_items
    Ad.joins(:item).pluck(:name).uniq
  end

  # Checks if we're on the Madloba demo website
  def demo?
    request.original_url.include? ('demo.madloba.org')
  end


  # methods for model-related controller (location, item, category, ad)
  # --------------------------------------------------------------------
  def requires_user
    if !user_signed_in?
      redirect_to '/user/login'
    end
  end

  def record_not_found
    flash[:error] = t('home.record_not_exist')
    if current_user && current_user.admin?
      redirect_to user_managerecords_path
    else
      redirect_to root_path
    end
  end

  # display user's locations, to allow them to tie existing one to an ad.
  def user_locations_number
    if (current_user && current_user.locations)
      current_user.locations.count
    else
      0 # no registered user, or registered user with no locations.
    end
  end

  # Defines whether or not the user is on the admin panel.
  # That will have an impact on the bootstrap class used for the navigation, for example
  def is_in_admin_panel
    (request.original_url.include? ('/user')) && (current_user)
  end

  # Defines whether or not the user is going through the setup pages.
  # That will have an impact on the content of the navigation bar.
  def is_in_setup_mode
    request.original_url.include? ('/setup')
  end


  # Helpers for map related pages
  # -----------------------------
  def getGeocodesFromAddress(address)
    geocodes = nil
    response = getNominatimWebserviceResponse(address)
    if response
      if response[0]
        geocodes = {}
        response_node = response[0]
        if (response_node['lat'] && response_node['lon'])
          geocodes['lat'] = response_node['lat']
          geocodes['lon'] = response_node['lon']
        end
      end
    end
    return geocodes
  end

  def getNominatimWebserviceResponse(location)
    url = OSM_NOMINATIM_URL % {location: location}
    safeurl = URI.parse(URI.encode(url))
    response = HTTParty.get(safeurl)
    if !response.success?
      response = nil
    end

    return response
  end


  def getAddressFromGeocodes(latitude,longitude)
    address = nil
    url = "http://open.mapquestapi.com/nominatim/v1/reverse.php?format=json&lat=#{latitude}&lon=#{longitude}"
    safeurl = URI.parse(URI.encode(url))
    response = HTTParty.get(safeurl)
    if !response.success?
      raise response.response
    else
      address = response['display_name']
    end
    return address
  end

  def valid_float?(str)
    # The double negation turns this into an actual boolean true - if you're
    # okay with "truthy" values (like 0.0), you can remove it.
    !!Float(str) rescue false
  end


  private

  # Info to display several markers on ads#show (1 marker per item)
  def getMapSettingsWithSeveralItems(location, has_center_marker, clickable_map_marker, items)
    c = MapInfo.new(lcoation: location, center_marker: has_center_marker, clickable: clickable_map_marker)

    # Specific info related to ads#show
    @map_settings['ad_show'] = []
    if location.is_area
      # Getting information whether it's a postal code area, or a district
      @map_settings['ad_show_is_area'] = true
      items_to_show = []
      items.each do |item|
        items_to_show << item.capitalized_name
      end
      @map_settings['popup_message'] = items_to_show.join(', ')
    else
      # Getting information as an exact address location
      @map_settings['ad_show_is_area'] = false
      items.each_with_index do |item, index|
        @map_settings['ad_show'][index] = {}
        @map_settings['ad_show'][index]['icon'] = item.category.icon
        @map_settings['ad_show'][index]['color'] = item.category.marker_color
        @map_settings['ad_show'][index]['item_name'] = item.name
      end
      # Overriding 'zoom_level' data from the database with the max zoom level,
      # only for the ads@show page and if we're showing an exact address.
      @map_settings['zoom_level'] = MAX_ZOOM_LEVEL;
    end

  end

  # Map settings function that initialize hash to be used to create map tiles.
  def get_map_tiles_attribution(api_keys)
    result = {}
    result['mapbox'] = {}
    result['mapbox']['tiles_url'] = MAPBOX_TILES_URL % {api_key: api_keys['mapbox']}
    result['mapbox']['attribution'] = MAPBOX_ATTRIBUTION

    result['mapquest'] = {}
    result['mapquest']['tiles_url'] = MAPQUEST_TILES_URL % {api_key: api_keys['mapquest']}
    result['mapquest']['attribution'] = ''

    result['osm'] = {}
    result['osm']['tiles_url'] = OSM_TILES_URL
    result['osm']['attribution'] = OSM_ATTRIBUTION

    return result
    end

  # Define whether the app is deployed on Heroku or not.
  def is_on_heroku
    ENV['MADLOBA_IS_ON_HEROKU'].downcase == 'true'
  end

end
