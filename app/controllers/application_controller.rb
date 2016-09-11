class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :check_if_setup
  before_action :load_javascript_text
  before_action :allow_iframe_requests
  before_action :set_locale

  include ApplicationHelper
  include Pundit
  include SimpleCaptcha::ControllerHelpers

  helper :'user/location_form'

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception,
                :with => :render_error
    rescue_from StandardError,
                :with => :render_error
    rescue_from ActiveRecord::RecordNotFound,
                :with => :render_not_found
    rescue_from ActionController::RoutingError,
                :with => :render_not_found
    rescue_from ActionController::UnknownController,
                :with => :render_not_found
    rescue_from Pundit::NotAuthorizedError,
                with: :user_not_authorized
  end

  # In the Settings table, if 'setup_step' is set to 1 or 'chosen_language' has no value, it means that the installation process
  # is not complete. Redirects to setup screens if it is the case.
  def check_if_setup
    current_url = request.original_url
    chosen_language = Rails.cache.fetch(CACHE_CHOSEN_LANGUAGE) {Setting.where(key: 'chosen_language').pluck(:value).first}
    no_chosen_language = chosen_language.empty? && !(current_url.include? 'setup/language')
    setup_debug_mode = Rails.configuration.setup_debug_mode && !(current_url.include? 'setup')

    if setup_debug_mode
      redirect_to setup_language_path
    else
      if no_chosen_language
        # If the locale has never been specified (even during the setup process), redirect to the setup language page.
        redirect_to setup_language_path
      elsif !((current_url.include? 'setup') || (current_url.include? 'user/register') || (current_url.include? 'getCityGeocodes'))
        # Redirect to the setup pages if it has never been completed.
        setup_step_value = Rails.cache.fetch(CACHE_SETUP_STEP) {Setting.where(key: 'setup_step').pluck(:value).first.to_i}
        if setup_step_value == 1
          redirect_to setup_language_path
        end
      end
    end
  end

  # Uses the 'gon' gem to load the text that appears in javascript files.
  def load_javascript_text
    gon.vars = t('general_js')
  end


  # Allows the website to be embedded in an iframe.
  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end

  # Choose the right locale among the ones that are available.
  def set_locale
    chosen_language = Rails.cache.fetch(CACHE_CHOSEN_LANGUAGE) {Setting.where(key: 'chosen_language').pluck(:value).first}
    if chosen_language && !chosen_language.empty?
      l = chosen_language
    else
      l = I18n.default_locale
    end
    I18n.locale = l
  end

  # Redirects after signing in.
  def after_sign_in_path_for(resource)
    sign_in_url = new_user_session_url
    if request.referer == sign_in_url
      super
    else
      if stored_location_for(resource)
        stored_location_for(resource)
      elsif user_signed_in?
        user_index_path
      end
    end
  end

  # Method called on Ajax call, to define geocodes of a location.
  def getCityGeocodes
    if params['type'] != 'area'
      if params['street_number'].present? && params['address'].present?
        address_street = "#{params['street_number']} #{params['address']}"
      elsif params['address']
        address_street = params['address']
      end
    end

    if params['city'].nil? || params['country'].nil?
      # If this inforamtion doesn't come from the page, we get it from the Settings table
      settings = Setting.where(key: %w(city state country))
      settings.each do |setting|
        params[setting.key] = setting.value
      end
    end

    location_info = [address_street, params['postal_code'], params['city'], params['state'], params['country']]
    address = build_up_address(location_info)

    # Getting geocodes for this address.
    response = getGeocodesFromAddress(address)

    if response.nil?
      # We're trying to get the geocodes again, but this time without the postal code and the street number
      location_info = [params['address'], params['city'], params['state'], params['country']]
      address = build_up_address(location_info)
      response = getGeocodesFromAddress(address)

      if response
        address_found = t('home.full_not_found_map_position', address: address)
        response['zoom_level'] = CLOSER_ZOOM_LEVEL
        response['status'] = 'ok'
      else
        address_found = t('home.not_found_map_position')
        response = {}
        response['zoom_level'] = Setting.find_by_key('zoom_level').value
        response['status'] = 'not_found'
      end
    else
      address_found = t('home.map_positioned_found', address: address)
      response['zoom_level'] = CLOSER_ZOOM_LEVEL
      response['status'] = 'ok'
    end

    response['address_found'] = address_found

    render json: response
  end

  # Method used by the Ajax call, when onclick on the home page "Search" button, when
  # the location field is not empty
  # This method returns the Nominatim ws responses, like the ones returned when a location is
  # searched on http://www.openstreetmap.org
  def getNominatimLocationResponses
    # We append the city and the country to the searched location.
    location_value = params['location']
    additional_locations = {}

    settings = Setting.where(key: %w(city state country))
    settings.each do |setting|
      additional_locations[setting.key] = setting.value
    end

    %w(city state country).each do |key|
      if additional_locations[key] && additional_locations[key] != ''
        location_value += ", #{additional_locations[key]}"
      end
    end

    locations_results = []
    response = getNominatimWebserviceResponse(location_value)
    if response
      if response.to_a.any?
        # The response consists of several propositions, in terms of specific locations
        response.each do |response_location|
          locations_results << response_location.select {|key,value| %w(lat lon display_name).include? key}
        end
      else
        # The search didn't return anything.
        error_hash = {}
        error_hash['error_key'] = t('home.loc_not_found')
        locations_results << error_hash
      end
    else
      # An error occurred while getting info from OSM's nominatim webservice call.
      error_hash = {}
      error_hash['error_key'] = t('home.server_error')
      locations_results << error_hash
    end
    render json: locations_results
  end

  # Returns a list of items, to appear in popup when using autocompletion.
  def get_items
    typeahead_type = params[:type]
    search_type = params[:q]

    if typeahead_type == PREFETCH_AD_ITEMS
      # 'prefetch_ad_items' type - prefetching data when item typed in main navigation search bar.
      matched_items = Ad.joins(:items).where(is_giving: search_type=='searching').pluck(:name).uniq
    elsif typeahead_type == PREFETCH_ALL_ITEMS
      matched_items = Item.all.pluck(:id, :name)
    elsif typeahead_type == SEARCH_IN_AD_ITEMS
      # 'search_ad_items' type - used on Ajax call, when item typed in main navigation search bar.
      matched_items = Ad.joins(:items).where('items.name LIKE ? and ads.is_giving = ?', "%#{params[:item].downcase}%", search_type=='searching').pluck(:name).uniq
    elsif typeahead_type == SEARCH_IN_ALL_ITEMS
      # 'search_items' type - used on Ajax call, when item typed in drop-down box, when adding items,
      # in ads#edit and ads#new pages.
      matched_items = Item.where('name LIKE ?', "%#{params[:item].downcase}%").pluck(:id, :name)
    end

    result = []
    if [PREFETCH_AD_ITEMS, SEARCH_IN_AD_ITEMS].include? typeahead_type
      matched_items.each do |match|
        result << {value: match}
      end
    else
      matched_items.each do |match|
        result << {id: match[0].to_s, value: match[1]}
      end
    end

    render json: result
  end

  private

  # Redirection when current user does not have the permission to go to
  # the requested page (authorization managed by Pundit)
  def user_not_authorized
    flash[:error] = t('config.not_authorized')
    redirect_to(request.referrer || root_path || user_path)
  end

  def build_up_address(location_info)
    address = ''
    location_info.each do |info|
      if info.present?
        if address != ''
          address += ", #{info}"
        else
          address = info
        end
      end
    end
    address
  end

  protected

  # Method to render 404 page
  def render_not_found(exception)
    ExceptionNotifier.notify_exception(exception, env: request.env, :data => {:message => "was doing something wrong"})
    respond_to do |format|
      format.html { render template: 'errors/error404', status: 404 }
      format.all { render nothing: true, status: 404}
    end
  end

  # Method to render 500 page
  def render_error(exception)
    ExceptionNotifier.notify_exception(exception, env: request.env)
    respond_to do |format|
      format.html { render template: 'errors/error500', status: 500 }
      format.all { render nothing: true, status: 500}
    end
  end

end
