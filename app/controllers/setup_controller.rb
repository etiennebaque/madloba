class SetupController < ApplicationController
  before_action :check_setup_step

  include ApplicationHelper

  # We first check that the user really has to go through the setup process.
  # The process finishes once the user reaches the 'All done' page.
  def check_setup_step
    setup_step = Setting.find_or_create_by(key: 'setup_step')
    setup_step_val = setup_step.value.to_i
    if setup_step_val == 0
      # The app is already good to go, the user must be redirected to root
      redirect_to root_path
    end
  end

  # ---------------------------------------
  # Method for 'language' page (intro page)
  # ---------------------------------------
  def show_choose_language
    @current_step = 0
    chosen_language = Rails.cache.fetch(CACHE_CHOSEN_LANGUAGE) {Setting.where(key: 'chosen_language').pluck(:value).first}
    if chosen_language && !chosen_language.empty?
      @current_language = chosen_language
    else
      # Default locale
      @current_language = 'en'
    end

    render 'setup/language'
  end

  def process_chosen_language
    chosen_language = Setting.find_or_create_by(key: 'chosen_language')
    chosen_language.update_attributes(value: params['language'])

    # Cache the chosen locale
    Rails.cache.write(CACHE_CHOSEN_LANGUAGE, params['language'])

    redirect_to setup_path
  end

  # --------------------------------------
  # Method for 'Welcome' page
  # --------------------------------------
  def show_welcome
    @current_step = 1
    render 'setup/welcome'
  end


  # --------------------------------------
  # Methods for 'General information' page
  # --------------------------------------
  def show_general
    records = Setting.where(key: %w(app_name description))
    @settings = {}
    records.each do |setting|
      @settings[setting.key] = setting.value
    end
    @current_step = 2

    render 'setup/general'
  end

  def process_general
    if (params['app_name'].nil?) || (params['app_name'] && params['app_name'] == '')
      flash[:error] = t('setup.name_cant_be_blank')
      render 'setup/general'
    end

    keys = %w(app_name description)
    keys.each do |key|
      record = Setting.where(key: key).first
      if record
        record.update_attributes(value: params[key])
      else
        record = Setting.new(key: key, value: params[key])
      end
      record.save
    end

    # Caching application name.
    Rails.cache.write(CACHE_APP_NAME, params['app_name'])

    redirect_to setup_map_path
  end

  # -----------------------------------------
  # Methods for 'Map settings' page
  # -----------------------------------------
  def show_map
    getMapSettings(nil, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)
    @mapSettings['page'] = 'mapsettings'
    @current_step = 3

    render 'setup/map'
  end

  def process_map
    lat = params['hiddenLatId']
    lng = params['hiddenLngId']
    if lat && lat != '' && lng && lng != ''
      map_center = "#{lat},#{lng}"
      settings_hash = {city: params['city'],
                       state: params['state'],
                       country: params['country'],
                       zoom_level: params['zoom_level'],
                       map_center_geocode: map_center}
      settings_hash.each {|key, value|
        setting_record = Setting.find_by_key(key)
        if setting_record.nil?
          setting_record = Setting.new(key: key, value: value)
        else
          setting_record.update_attribute(:value, value)
        end
        setting_record.save
      }

      if is_on_heroku
        redirect_to setup_admin_path
      else
        redirect_to setup_image_path
      end
    else
      flash[:error] = t('setup.select_geocodes')
      getMapSettings(nil, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)
      render 'setup/map'
    end
  end

  # -----------------------------------------
  # Methods for 'Image storage' page
  # -----------------------------------------
  def show_image

    @storage_choices = [[IMAGE_NO_STORAGE, t('setup.option_no_storage')],
                        [IMAGE_AMAZON_S3, t('setup.option_s3')]]

    if !is_on_heroku
      @storage_choices << [IMAGE_ON_SERVER, t('setup.option_server')]
    else
      # If app deployed on Heroku, we should not be here. Redirection to next step, admin page.
      redirect_to setup_admin_path
    end

    @current_step = 4
    image_storage = Setting.find_or_create_by(key: 'image_storage')
    @current_image_choice = image_storage.value

    render 'setup/image'
  end


  def process_image
    setting = Setting.find_or_create_by(key: 'image_storage')
    setting.value = params['storage_choice']

    if setting.save
      # Caching image strategy choice.
      Rails.cache.write(CACHE_IMAGE_STORAGE, params['storage_choice'])
      redirect_to setup_admin_path
    else
      flash[:error] = t('setup.image_error')
      render 'setup/image'
    end
  end

  # -----------------------------------------
  # Methods for 'Creation of admin user' page
  # -----------------------------------------
  def show_admin
    @user = User.new
    @user.role = 1 # New user will be admin.
    @current_step = 5
    render 'setup/admin'
  end

  def process_admin
    # Creation of admin user takes place in 'users#create'
  end


  # --------------------------------------
  # Method for 'All done' page (last page)
  # --------------------------------------
  def show_finish
    setup_step = Setting.find_or_create_by(key: 'setup_step')
    setup_step.update_attribute(:value, '0')
    setup_step.save

    # Caching this value.
    Rails.cache.write(CACHE_SETUP_STEP, 0)

    @current_step = 6

    render 'setup/finish'
  end

end
