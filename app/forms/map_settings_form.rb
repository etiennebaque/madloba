class MapSettingsForm

  ATTRIBUTES = [:mapbox_api_key, :mapbox_map_name, :mapquest_api_key]
  SETTINGS_ATTRIBUTES = [:chosen_map, :latitude, :longitude, :city, :state, :country, :zoom_level]

  attr_accessor(*(ATTRIBUTES+SETTINGS_ATTRIBUTES))

  def initialize
    mapbox = MapTile.mapbox
    mapquest = MapTile.mapquest
    settings = Setting.all

    self.chosen_map = settings.find_by_key('chosen_map')
    %w(api_key map_name).each {|key| self.send("mapbox_#{key}=", mapbox.send(key))}
    self.mapquest_api_key = mapquest.api_key
    SETTINGS_ATTRIBUTES.each {|key| self.send("#{key}=", settings.find_by_key(:key))}
  end


end