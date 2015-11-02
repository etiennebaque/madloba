class User::AdminPanelController < ApplicationController
  before_action :authenticate_user!, except: [:getAreaSettings]
  before_filter :requires_user, except: [:getAreaSettings]

  before_action :latitude_longitude_should_be_numeric, only: [:update_mapsettings]
  before_action :postal_code_greater_than_area_code, only: [:update_areasettings]

  include ApplicationHelper

  # Style used to display messages on 'Area settings' page
  STYLES = {success: 'text-success', error: 'text-danger' }

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

      if Category.count == 1
        # Show a warning message, if there's only 1 category (the default one, most likely).
        @messages << {text: t('admin.one_category_html'), type: 'danger'}
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
          @messages << {text: t('admin.no_mapbox_account_html', mapbox_website: view_context.link_to('Mapbox', 'http://www.mapbox.com', {target: '_blank'})),
                        type: 'info'}
        end

        # Show a message if no MapQuest key has been entered, in "Map settings"
        if (setting.key == 'mapquest_api_key' && (setting.value == '' || setting.value.nil?))
          @messages << {text: t('admin.no_mapquest_account_html', mapquest_website: view_context.link_to('MapQuest Developers', 'http://developer.mapquest.com/web/info/account/app-keys', {target: '_blank'})),
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
    %w(app_name description contact_email ad_max_expire facebook twitter pinterest
              link_one_label link_one_url link_two_label link_two_url
              link_three_label link_three_url link_four_label link_four_url)
  end

  def map_settings_keys
    %w(map_box_api_key mapquest_api_key map_center_geocode chosen_map city state country zoom_level)
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
    @map_settings = getMapSettings(nil, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)

    # More settings to get, in addition to the one we already get in getMapSettings.
    settings = Setting.where(key: %w(city state country))
    if settings
      settings.each do |setting|
        @map_settings[setting.key] = setting.value
        # Updating cache value
        if setting.key == 'city'
          Rails.cache.write(CACHE_CITY_NAME, setting.value)
        end
      end
    end

    # Adding this element to the hash, in order to get the 'zoomend' event working,
    # only for the map settings page (needed to define zoom level).
    @map_settings['page'] = 'mapsettings'

  end

  def update_mapsettings
    lat = params['hiddenLatId']
    lng = params['hiddenLngId']

    if is_demo
      # If this is the Madloba Demo, then we update only the chosen_map. The other parameters cannot be changed.
      setting_record = Setting.find_by_key(:chosen_map)
      setting_record.update_attribute(:value, params['chosen_map'])
      flash[:setting_success] = t('admin.map_settings.update_success_demo')

    elsif ((lat.is_a? Numeric) && (lng.is_a? Numeric)) || lat != nil || lng != nil
      # All the information on the map settings page that can be saved
      map_settings_keys.each do |key|
        setting_record = Setting.find_by_key(key)
        if setting_record
          if key == 'map_center_geocode'
            setting_record.update_attributes(value: "#{lat},#{lng}")
          else
            setting_record.update_attributes(value: params[key])
          end
        end
      end

      if ((params['map_box_api_key'] == '' && params['chosen_map'] == 'mapbox') || (params['mapquest_api_key'] == '' && params['chosen_map'] == 'mapquest'))
        # if there is no longer any Mapbox or MapQuest keys, we get back to the default map type, osm.
        setting_record = Setting.find_by_key('chosen_map')
        setting_record.update_attributes(value: 'osm')
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

    @map_settings = getMapSettings(nil, HAS_NOT_CENTER_MARKER, NOT_CLICKABLE_MAP)

    # Adding this flag to add leaflet draw tool to the map, on the "Area settings" page.
    # Drawing tool added in initLeafletMap(), in custom-leaflet.js
    @map_settings['page'] = 'areasettings'

    districts = District.all.select(:id, :name, :bounds)
    @districts = []
    districts.each do |d|
      if d.bounds.present?
        bounds = JSON.parse(d.bounds)
        bounds['properties']['id'] = d.id
        bounds['properties']['name'] = d.name
        @districts.push(bounds)
      end
    end  
    @area_types = @map_settings['area_type'].split(',')
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

    # Updating cache value, for area types.
    Rails.cache.write(CACHE_AREA_TYPE, area_type_param)

    flash[:setting_success] = t('admin.map_settings.area_update_success')
    redirect_to user_areasettings_path

  end
  
  # Save/update a district after it has been drawn on a map and named, on the "Area settings" page.
  def save_district
    bounds_geojson = params[:bounds]
    district_name = params[:name]

    style, message, status = '', '', ''

    # Creation of district
    d = District.new(name: district_name, bounds: bounds_geojson)
    if d.save
      message = t('admin.area_settings.save_success')
      style = STYLES[:success]
      status = 'ok'
      Rails.cache.write(CACHE_DISTRICTS, District.select(:id, :name, :bounds))
    else
      message = t('admin.area_settings.error_save_district')
      style = STYLES[:error]
    end

    render json: {'status' => status, 'id' => d.id, 'message' => message, 'style' => style, 
      'district_name' => district_name, 'district_color' => DISTRICT_COLOR}
  end

  # Updating the name of an existing district
  def update_district_name
    d = District.find(params[:id].to_i)
    style, message = '', ''
    if d && d.update_attributes(name: params[:name])
      message = t('admin.area_settings.save_name_success')
      style = STYLES[:success]
      Rails.cache.write(CACHE_DISTRICTS, District.select(:id, :name, :bounds))
    else
      message = t('admin.area_settings.error_name_save')
      style = STYLES[:error]
    end

    render json: {'message' => message, 'style' => style}
  end   

  # Updating the boundaries of existing districts
  def update_districts
    districts = JSON.parse(params[:districts])
    style, message = '', ''
    districts.each do |district|
      # Editing an existing district at a time.
      district_id = district['properties']['id']
      district_name = district['properties']['name']
      if district_id
        district['properties'] = {}
        d = District.find(district_id.to_i)
        if d.update_attributes(name: district_name, bounds: district.to_json)
          message = t('admin.area_settings.update_success')
          style = STYLES[:success]
          Rails.cache.write(CACHE_DISTRICTS, District.select(:id, :name, :bounds))
        else
          message = t('admin.area_settings.error_update_district')
          style = STYLES[:error]
          break
        end
      end
    end

    render json: {'message' => message, 'style' => style}
  end 

  # Deletes existing districts
  def delete_districts
    ids_to_delete = params[:ids]
    style, message = '', ''
    ids_to_delete.each do |id|
      d = District.find(id)
      if d.delete
        message = t('admin.area_settings.delete_success')
        style = STYLES[:success]
        Rails.cache.write(CACHE_DISTRICTS, District.select(:id, :name, :bounds))
      else
        message = t('admin.area_settings.delete_error')
        style = STYLES[:error]
      end  
    end  

    render json: {'message' => message, 'style' => style}

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
    %w(facebook twitter pinterest)
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
