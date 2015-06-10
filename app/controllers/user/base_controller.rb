class User::BaseController < ApplicationController
  before_action :authenticate_user!, except: [:getAreaSettings]
  before_filter :requires_user, except: [:getAreaSettings]

  before_action :latitude_longitude_should_be_numeric, only: [:update_mapsettings]
  before_action :postal_code_greater_than_area_code, only: [:update_areasettings]

  layout 'home'

  include ApplicationHelper

  def requires_user
    if !user_signed_in?
      redirect_to '/user/login'
    end
  end

  def index
    @messages = []
    if (current_user.admin?)
      # To-do list creation
      empty_social = 0

      if Category.count == 0
        # Show a danger message, if no category has not been defined yet.
        @messages << {text: t('admin.no_categories_html'), type: 'danger'}
      end

      settings = Setting.all
      settings.each do |setting|
        # Show a message if no area has been defined, in "Area settings"
        if (setting.key == 'area_type' && (setting.value == '' || setting.value.nil?))
          @messages << {text: t('admin.no_area_type_html'),
                        type: 'danger'}
        end

        # Show a message if no Mapbox key has been entered, in "Map settings"
        if (setting.key == 'map_box_api_key' && (setting.value == '' || setting.value.nil?))
          @messages << {text: t('admin.no_mapbox_account_html', href: view_context.link_to('Mapbox', 'http://www.mapbox.com', {target: '_blank'})),
                        type: 'info'}
        end

        # Show a message if no MapQuest key has been entered, in "Map settings"
        if (setting.key == 'mapquest_api_key' && (setting.value == '' || setting.value.nil?))
          @messages << {text: t('admin.no_mapquest_account_html', href: view_context.link_to('MapQuest Developers', 'http://developer.mapquest.com/web/info/account/app-keys', {target: '_blank'})),
                        type: 'info'}
        end

        # Show a message if there is no website description, in "General settings"
        if (setting.key == 'description' && (setting.value == '' || setting.value.nil?))
          @messages << {text: t('admin.no_website_description'),
                        type: 'info'}
        end

        if ((social_networks.include?setting.key) && (setting.value == '' || setting.value.nil?))
          empty_social += 1
        end
      end

      # Show a message if no social network contact has been entered, in "General settings"
      if empty_social == social_networks.length
        @messages << {text: t('admin.no_social'), type: 'info'}
      end

    end
  end

  # ---------------------------------------
  # Admin: "Manage records", "Manage users"
  # ---------------------------------------
  def managerecords
    authorize :admin, :managerecords?
  end

  def manageusers
    authorize :admin, :manageusers?
  end


  # --------------------------------------
  # Methods for 'General settings' screens
  # --------------------------------------
  def general_settings_keys
    return %w(app_name description contact_email ad_max_expire facebook twitter pinterest
              link_one_label link_one_url link_two_label link_two_url
              link_three_label link_three_url link_four_label link_four_url)
  end

  def generalsettings
    authorize :admin, :generalsettings?

    settings = Setting.where(key: general_settings_keys)

    @settings = {}
    settings.each do |setting|
      @settings[setting.key] = setting.value
    end

    @description_remaining = 500
    if @settings['description'] && @settings['description'].length > 0
      @description_remaining = 500 - @settings['description'].length
    end

  end

  def update_generalsettings
    general_settings_keys.each do |key|
      if key == 'app_name'
        if params[key].present?
          app_name_settings = Setting.find_by_key(key)
          app_name_settings.update_attribute(:value, params[key])

          # Updating cached value.
          Rails.cache.write(CACHE_APP_NAME, params[key])
        else
          # the application name has been deleted. We can't save an empty app name.
          flash[:setting_success] = 0
          break
        end
      else
        app_name_settings = Setting.find_by_key(key)
        cleaned_data = params[key]
        if %w(_url facebook pinterest).any? {|word| key.include?(word) }
          # Cleaning up the urls
          if (params[key] != '') && (!params[key].include? 'http')
            cleaned_data = "http://#{params[key]}"
          end
        elsif key == 'ad_max_expire'
          Rails.cache.write(CACHE_MAX_DAYS_EXPIRE, cleaned_data)
        end
        app_name_settings.update_attribute(:value, cleaned_data)
      end
      flash[:setting_success] = 1
    end
    redirect_to user_generalsettings_path
  end


  # ----------------------------------
  # Methods for 'Map settings' screens
  # ----------------------------------
  def mapsettings
    authorize :admin, :mapsettings?
    @mapSettings = getMapSettings(nil, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)

    # More settings to get, in addition to the one we already get in getMapSettings.
    settings = Setting.where(key: %w(city state country))
    if settings
      settings.each do |setting|
        @mapSettings[setting.key] = setting.value
        # Updating cache value
        if setting.key == 'city'
          Rails.cache.write(CACHE_CITY_NAME, setting.value)
        end
      end
    end

    # Adding this element to the hash, in order to get the 'zoomend' event working,
    # only for the map settings page (needed to define zoom level).
    @mapSettings['page'] = 'mapsettings'

    # Initializing the map type drop down box.
    @options_for_maptype_select = []
    @options_for_maptype_select << ['OpenStreetMap', 'osm']
    # If a Mapbox and a MapQuest keys has been provided, then we include them in the drop down box
    if @mapSettings['map_box_api_key'] && @mapSettings['map_box_api_key'] != ''
      @options_for_maptype_select << ['Mapbox', 'mapbox']
    end
    if @mapSettings['mapquest_api_key'] && @mapSettings['mapquest_api_key'] != ''
      @options_for_maptype_select << ['MapQuest', 'mapquest']
    end

  end

  def update_mapsettings
    lat = params['hiddenLatId']
    lng = params['hiddenLngId']

    if is_demo
      # If this is the Madloba Demo, then we update only the chosen_map. The other parameters cannot be changed.
      setting_record = Setting.find_by_key(:chosen_map)
      setting_record.update_attribute(:value, params['maptype'])
      flash[:setting_success] = t('admin.map_settings.update_success_demo')

    elsif ((lat.is_a? Numeric) && (lng.is_a? Numeric)) || lat != nil || lng != nil
      # All the information on the map settings page that can be saved
      new_map_center = "#{lat},#{lng}"
      settings_hash = {:map_box_api_key => params['mapBoxApiKey'],
                       :mapquest_api_key => params['mapQuestApiKey'],
                       :chosen_map => params['maptype'],
                       :city => params['city'],
                       :state => params['state'],
                       :country => params['country'],
                       :zoom_level => params['zoom_level'],
                       :map_center_geocode => new_map_center}
      settings_hash.each {|key, value|
        setting_record = Setting.find_by_key(key)
        setting_record.update_attribute(:value, value)
      }

      if (params['mapBoxApiKey'] == '' || params['mapQuestApiKey'] == '')
        # if there is no longer any Mapbox key, we get back to the default map type, osm.
        setting_record = Setting.find_by_key('chosen_map')
        setting_record.update_attribute(:value, 'osm')
      end
      flash[:setting_success] = t('admin.map_settings.update_success')
    end

    redirect_to user_mapsettings_path
  end


  # -----------------------------------
  # Methods for 'Area settings' screen
  # ----------------------------------
  def areasettings
    authorize :admin, :areasettings?

    @mapSettings = getMapSettings(nil, HAS_NOT_CENTER_MARKER, CLICKABLE_MAP_AREA_MARKER)

    @districts = District.all.order('name asc')
    @districts_hash = {}
    @district_index = 0
    @districts.each do |district|
      @districts_hash[district.id] = {name: district.name, latitude: district.latitude, longitude: district.longitude}
      if district.id >= @district_index
        # @district_index will be used as a key for @district_hash, when adding new district dynamically.
        @district_index = district.id + 1
      end
    end

    @area_types = @mapSettings['area_type'].split(',')

  end

  def update_areasettings
    area_type_param = ''
    if params['area_type']
      area_type_param = params['area_type'].join(',')
    end
    settings_hash = {:area_type => area_type_param,
                     :area_length => params['area_length'],
                     :postal_code_length => params['postal_code_length']}

    settings_hash.each {|key, value|
      setting_record = Setting.find_by_key(key)
      setting_record.update_attribute(:value, value)
    }

    flash[:setting_success] = t('admin.map_settings.update_success')
    redirect_to user_areasettings_path

  end

  # Called via Ajax, when updating district values, in the area setting page.
  def update_districts
    districts = params[:data]
    message = ''
    districts.each do |id,district|
      this_district = District.find_by_id(id)
      if (this_district)
        if district['to_delete']
          # We delete this district
          this_district.delete
        else
          # We update an existing district
          this_district.update_attributes(name: district['name'], latitude: district['latitude'], longitude: district['longitude'])
        end
      else
        this_district = District.new(district)
      end
      if this_district.save
        message = 'ok'
      else
        message = t('admin.area_settings.error_update_district')
        break
      end
    end

    render json: {'status' => message}
  end

  def getAreaSettings
    code_and_area = Setting.where(key: %w(postal_code_length area_length)).pluck(:value)

    if (code_and_area) && (code_and_area.length == 2)
      render json: {'code' => code_and_area[0], 'area' => code_and_area[1]}
    else
      render json: {'error' => true}
    end

  end

  # --------------------------------
  # Methods for regular user screens
  # --------------------------------
  def manageads
    @ads = Ad.includes(:items).where(user: current_user)
    @locations = Location.where(user: current_user)
  end

  def manageprofile
    @user = current_user
  end

  private

  def social_networks
    ['facebook', 'twitter', 'pinterest']
  end


  def latitude_longitude_should_be_numeric
    # before-filter check used on map setting page.
    lat = params['latId']
    lng = params['lngId']

    if (lat != nil && lng != nil)
      if (!(lat.empty?) && !(lng.empty?))
        if !(valid_float?(lat)) || !(valid_float?(lng))
          flash[:page_error] = t('admin.map_settings.should_be_numeric')
          redirect_to user_mapsettings_path
        end
      else
        flash[:page_error] = t('admin.map_settings.cannot_be_empty')
        redirect_to user_mapsettings_path
      end
    end
  end

  def postal_code_greater_than_area_code
    postal_code_length = params['postal_code_length']
    area_length = params['area_length']

    if (!(postal_code_length.empty?) && !(area_length.empty?))
      if postal_code_length.to_i < area_length.to_i
        flash[:page_error] = t('admin.map_settings.postal_area_error')
        redirect_to user_mapsettings_path
      end
    end

  end


end
