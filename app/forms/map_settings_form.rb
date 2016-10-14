class MapSettingsForm < ApplicationForm
  include MapHelper

  attr_accessor(*(MAP_SERVICE_ATTRIBUTES+SETTINGS_ATTRIBUTES))

  def initialize(params = nil)
    if params.present?
      params.each do |k,v|
        self.send("#{k}=", v)
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

  def options_for_zoom_level
    options = []
    (1..18).each {|n| options << [n,n]}
    options
  end

  def submit
    if demo?
      # If this is the Madloba Demo, then we update only the chosen_map. The other parameters cannot be changed.
      setting_record = Setting.find_by_key(:chosen_map)
      setting_record.update_attribute(:value, chosen_map)
      I18n.t('admin.map_settings.update_success_demo')
    else
      # All the information on the map settings page that can be saved
      MapTile.mapbox.update_attributes(api_key: mapbox_api_key, map_name: mapbox_map_name) if mapbox_api_key.present?
      MapTile.mapquest.update_attributes(api_key: mapquest_api_key) if mapquest_api_key.present?

      SETTINGS_ATTRIBUTES.each do |key|
        setting = Setting.find_by_key(key)
        if !self.send(key).nil? && setting.present?
          setting.update_attributes(value: self.send(key))
        end
      end

      # if there is no longer any Mapbox or MapQuest keys, we get back to the default map type, osm.
      Setting.find_by_key('chosen_map').update_attributes(value: 'open_street_map') if fallback_on_osm?

      I18n.t('admin.map_settings.update_success')
    end
  end

  private

  def demo?
    self.demo == 'true'
  end

  def fallback_on_osm?
    return true if mapbox_api_key.nil? && mapquest_api_key.nil?
    (mapbox_api_key.empty? && chosen_map == 'mapbox') || (mapquest_api_key.empty? && chosen_map == 'map_quest')
  end

end