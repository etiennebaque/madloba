class MapTile < ActiveRecord::Base

  def self.osm
    self.find_by_name('open_street_map')
  end

  def self.mapbox
    self.find_by_name('mapbox')
  end

  def self.mapquest
    self.find_by_name('map_quest')
  end

  def js_script_url
    url_needs_api_key? ? tile_url.gsub('<api_key>', api_key) : tile_url
  end

  def url_needs_api_key?
    tile_url.include?('<api_key>')
  end

  def display_name
    name.titleize.gsub(' ','')
  end

end
