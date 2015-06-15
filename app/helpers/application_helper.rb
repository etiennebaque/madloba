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
  def is_demo
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


  # Geocoding methods
  # -----------------
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
  def getMapSettingsWithSeveralItems(location, hasCenterMarker, clickableMapMarker, items)
    getMapSettings(location, hasCenterMarker, clickableMapMarker)

    # Specific info related to ads#show
    @mapSettings['ad_show'] = []
    if location.is_area
      @mapSettings['ad_show_is_area'] = true
      items_to_show = []
      items.each do |item|
        items_to_show << item.capitalized_name
      end
      @mapSettings['popup_message'] = items_to_show.join(', ')
    else
      @mapSettings['ad_show_is_area'] = false
      items.each_with_index do |item, index|
        @mapSettings['ad_show'][index] = {}
        @mapSettings['ad_show'][index]['icon'] = item.category.icon
        @mapSettings['ad_show'][index]['color'] = item.category.marker_color
        @mapSettings['ad_show'][index]['item_name'] = item.name
      end
      # Overriding 'zoom_level' data from the database with the max zoom level,
      # only for the ads@show page and if we're showing an exact address.
      @mapSettings['zoom_level'] = MAX_ZOOM_LEVEL;
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

  # ---------------------------------------------------
  # Global function to get settings to initialize a map
  # ---------------------------------------------------
  def getMapSettings(location, hasCenterMarker, clickableMapMarker)
    settings = Setting.where(key: %w(map_box_api_key map_center_geocode mapquest_api_key
                                     chosen_map area_type postal_code_length area_length zoom_level))
    @mapSettings = {}

    if settings
      settings.each do |setting|
        @mapSettings[setting.key] = setting.value
      end
    end

    # Used for text popup, tied to a map marker
    @mapSettings['marker_message'] = ''

    # Default geocode and zoom values
    @mapSettings['lat'] = 0
    @mapSettings['lng'] = 0

    # If we consider a location instance, geocodes will come from it, and we'll initialize marker-related information.
    if location && location.latitude && location.longitude
      location_type = location.loc_type
      @mapSettings['lat'] = location.latitude
      @mapSettings['lng'] = location.longitude

      if location_type == 'postal'
        area_code_length = Setting.where(key: %w(area_length)).pluck(:value).first
        @mapSettings['marker_message'] = "#{location.postal_code[0..area_code_length.to_i-1]} #{t('ad.area')}"
      elsif location_type == 'district'
        @mapSettings['marker_message'] = location.district.name
      else
        if location.name && location.name != ''
          @mapSettings['marker_message'] = location.name
        else
          @mapSettings['marker_message'] = location.full_address
        end
      end
      @mapSettings['is_area'] = ['postal','district'].include? location_type
    else
      # The location's geocodes have not been determined yet.
      # Getting map default center, to be used in this case.
      if @mapSettings['map_center_geocode'] && @mapSettings['map_center_geocode'] != ''
        # Using defined default map center
        default_geocodes = @mapSettings['map_center_geocode']
        geocodes_split = default_geocodes.split(',')
        @mapSettings['lat'] = geocodes_split[0]
        @mapSettings['lng'] = geocodes_split[1]
      end
    end

    # Setting up page-related map details (eg. should an event be triggered when map clicked? if so, what type of marker should appear?)
    @mapSettings['hasCenterMarker'] = hasCenterMarker
    @mapSettings['clickableMapMarker'] = clickableMapMarker

    # Initializing specific settings for OSM and Mapbox maps.
    api_keys = {}
    api_keys['mapbox'] = @mapSettings['map_box_api_key']
    api_keys['mapquest'] = @mapSettings['mapquest_api_key']
    @mapSettings.merge!(get_map_tiles_attribution(api_keys))

    @mapSettings['tiles_url'] = @mapSettings[@mapSettings['chosen_map']]['tiles_url']
    @mapSettings['attribution'] = @mapSettings[@mapSettings['chosen_map']]['attribution']

    # We also need to get the different defined areas (as opposed to exact locations)
    areas = Location.where(:loc_type => ['postal,district']).select(:id, :name, :postal_code, :latitude, :longitude)
    @mapSettings['areas'] = areas.as_json

    return @mapSettings
  end

  # Define whether the app is deployed on Heroku or not.
  def is_on_heroku
    ENV['MADLOBA_IS_ON_HEROKU'].downcase == 'true'
  end

end
