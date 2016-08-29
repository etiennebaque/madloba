class MapSettingsForm < ApplicationForm
  include MapHelper

  attr_accessor(*(MAP_SERVICE_ATTRIBUTES+SETTINGS_ATTRIBUTES))

  def initialize(map_info = nil)
    if map_info.present?
      MAP_SERVICE_ATTRIBUTES+SETTINGS_ATTRIBUTES.each do |key|
        self.send("#{key}=", map.info.send(key))
      end
    else
      init_map_settings
    end
  end

  def options_for_maptype_select
    options = [[@osm.display_name, @osm.name]]
    # If a Mapbox and a MapQuest keys has been provided, then we include them in the drop down box
    options << [@mapbox.display_name, @mapbox.name] if @mapbox.api_key.present?
    options << [@mapquest.display_name, @mapquest.name] if @mapquest.api_key.present?
    options
  end

  def submit

  end

end