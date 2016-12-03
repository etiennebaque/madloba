module MapHelper

  SETTINGS_ATTRIBUTES = [:chosen_map, :latitude, :longitude, :city, :state, :country, :zoom_level, :demo]
  MAP_SERVICE_ATTRIBUTES = [:mapbox_api_key, :mapbox_map_name, :mapbox_tile_url, :mapbox_attribution, :mapquest_api_key, :osm_tile_url, :osm_attribution]

  def init_map_settings
    @osm = MapTile.osm
    @mapbox = MapTile.mapbox
    @mapquest = MapTile.mapquest
    @settings = Setting.all

    self.chosen_map = @settings.find_by_key('chosen_map')
    %w(api_key map_name attribution).each {|key| self.send("mapbox_#{key}=", @mapbox.send(key))}
    self.mapbox_tile_url = @mapbox.url_builder
    self.mapquest_api_key = @mapquest.api_key
    %w(tile_url attribution).each {|key| self.send("osm_#{key}=", @osm.send(key))}

    SETTINGS_ATTRIBUTES.each {|key| self.send("#{key}=", @settings.find_by_key(key).try(:value))}
  end


end