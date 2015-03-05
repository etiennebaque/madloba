class SetupController < ApplicationController
  layout 'home'
  before_action :check_setup_step

  # We first check that the user really has to go through the setup process.
  def check_setup_step
    setup_step = Setting.where(key: 'setup_step').pluck(:value).first.to_i
    if setup_step == 0
      # The app is already good to go, the user must be redirected to root
      redirect_to root_path
    end
  end


  # --------------------------------------
  # Method for 'Welcome' page (first page)
  # --------------------------------------
  def show_welcome
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
    redirect_to setup_map_path
  end


  # -----------------------------------------
  # Methods for 'Map settings' page
  # -----------------------------------------
  def show_map
    getMapSettings(nil, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)
    @mapSettings['page'] = 'mapsettings'
    render 'setup/map'
  end

  def process_map
    lat = params['hiddenLatId']
    lng = params['hiddenLngId']
    if lat && lat != '' && lng && lng != ''
      map_center = "#{lat},#{lng}"
      settings_hash = {:city => params['city'],
                       :state => params['state'],
                       :country => params['country'],
                       :zoom_level => params['zoom_level'],
                       :map_center_geocode => map_center}
      settings_hash.each {|key, value|
        setting_record = Setting.find_by_key(key)
        if setting_record.nil?
          setting_record = Setting.new(key: key, value: value)
        else
          setting_record.update_attribute(:value, value)
        end
        setting_record.save
      }
      redirect_to setup_admin_path
    else
      flash[:error] = t('setup.select_geocodes')
      getMapSettings(nil, HAS_CENTER_MARKER, CLICKABLE_MAP_EXACT_MARKER)
      render 'setup/map'
    end
  end


  # -----------------------------------------
  # Methods for 'Creation of admin user' page
  # -----------------------------------------
  def show_admin
    @user = User.new
    @user.role = 1 # New user will be admin.
    render 'setup/admin'
  end

  def process_admin
    # Creation of admin user takes place in 'users#create'
  end


  # --------------------------------------
  # Method for 'All done' page (last page)
  # --------------------------------------
  def show_finish
    setup_step = Setting.find_by_key('setup_step')
    setup_step.update_attribute(:value, '0')
    setup_step.save

    render 'setup/finish'
  end

end
