module SetupHelper

  def map_settings
    records = Setting.where(key: %w(map_center_geocode city state country zoom_level))
    settings = {}
    records.each do |setting|
      if (setting.key == 'map_center_geocode')
        geocode = setting.value.split(',')
        settings['lat'] = geocode[0]
        settings['lng'] = geocode[1]
      else
        settings[setting.key] = setting.value
      end
    end
    return settings
  end

  def total_setup_pages
    # Total number of setup pages
    if on_heroku?
      5 # Skipping the image storage page, while on Heroku (functionality not developed for Heroku yet)
    else
      6
    end
  end

  # Very first page of setup process - choosing language for the application.
  def available_languages
    [['English','en'],['Français','fr']]
  end

end
