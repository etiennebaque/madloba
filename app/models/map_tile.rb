class MapTile < ActiveRecord::Base

  def self.osm
    self.find_by_name('openstreetmap')
  end

  def self.mapbox
    self.find_by_name('mapbox')
  end

  def self.mapquest
    self.find_by_name('mapquest')
  end

end
