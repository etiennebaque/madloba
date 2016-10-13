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
    request.original_url.include? 'demo.madloba.org'
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
  def admin_panel?
    (request.original_url.include? '/user') && (current_user)
  end

  # Defines whether or not the user is going through the setup pages.
  # That will have an impact on the content of the navigation bar.
  def setup_mode?
    request.original_url.include? '/setup'
  end

  def navigation_madloba_icon_path
    setup_mode? ? setup_path : root_path
  end

  def madloba_logo_file_name
    admin_panel? ? 'madloba_logo_green_40.png' : 'madloba_logo_50.png'
  end

  def navigation_madloba_title
    setup_mode? ? I18n.t('setup.madloba_setup') : site_name
  end

  def about_path_to_use
    (current_page?(root_url) || current_page?('/search')) ? '#' : about_path
  end


  # Helpers for map related pages
  # -----------------------------


  def nominatim_ws_response_for(location)
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

  # Define whether the app is deployed on Heroku or not.
  def on_heroku?
    ENV['MADLOBA_IS_ON_HEROKU'].downcase == 'true'
  end

end
