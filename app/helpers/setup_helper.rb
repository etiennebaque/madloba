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

end
