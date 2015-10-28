module User::AdminPanelHelper

  # On the Map Setting page, initializing the map type drop down box.
  def options_for_maptype_select(map_setting)
    options_for_maptype_select = []
    options_for_maptype_select << ['OpenStreetMap', 'osm']
    # If a Mapbox and a MapQuest keys has been provided, then we include them in the drop down box
    if map_setting['map_box_api_key'] && map_setting['map_box_api_key'] != ''
      options_for_maptype_select << ['Mapbox', 'mapbox']
    end
    if map_setting['mapquest_api_key'] && map_setting['mapquest_api_key'] != ''
      options_for_maptype_select << ['MapQuest', 'mapquest']
    end

    options_for_maptype_select

  end
end
