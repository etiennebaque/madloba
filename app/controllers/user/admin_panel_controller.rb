class User::AdminPanelController < ApplicationController
  before_action :authenticate_user!
  before_filter :requires_user

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
      Todo.all.each do |todo|
        @messages << todo.message_and_alert if !todo.condition_met?
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
    @form = MapSettingsForm.new
    @map_settings = MapInfo.new.to_hash

  end

  def update_mapsettings
    @form = MapSettingsForm.new(params[:map_settings_form])
    flash[:success] = @form.submit

    redirect_to user_mapsettings_path
  end


  # -----------------------------------
  # Methods for 'Area settings' screen
  # ----------------------------------
  def areasettings
    authorize :admin, :areasettings?

    @map_settings = MapInfo.new(has_center_marker: false, clickable: NOT_CLICKABLE_MAP).to_hash
    @area_types = Setting.area_types
  end

  def update_areasettings
    area_type_param = ''
    if params['area_type']
      area_type_param = params['area_type'].join(',')
    end

    settings_hash = {:area_type => area_type_param,
                     :area_length => params['area_length']}

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

end
