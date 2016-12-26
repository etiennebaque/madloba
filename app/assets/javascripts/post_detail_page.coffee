global = this

global.PostDetailPage = (postType) ->
  @postType = postType
  @init()

PostDetailPage::init = ->

  if postType == 'area'
    # Location where full address is not given (area only).
    # Placing a area marker on the map
    area = leaf.mapSettings.area
    marker = L.marker(
      [area.latitude, area.longitude],
      icon: markers.area_icon,
      bounceOnAdd: false,
      areaId: area.id
    )

    popup = L.popup().setContent(leaf.mapSettings.popup_message)
    marker.bindPopup popup, popupOptions()
    marker.addTo(leaf.map)

    leaf.map.setView [area.latitude, area.longitude], leaf.mapSettings['zoom_level']

  else
    # Exact address. Potentially several center markers on the map.
    # Displays a marker for each item tied to the ad we're showing the details of.
    # Using the Marker Cluster plugin to spiderfy this post's item marker.
    markers.group = new (L.markerClusterGroup)(
      spiderfyDistanceMultiplier: 2)

    post = leaf.mapSettings['marker']
    icon_to_use = L.AwesomeMarkers.icon(
      prefix: 'fa'
      markerColor: post['color']
      icon: post['icon'])

    map_center_marker = L.marker([
      leaf.my_lat
      leaf.my_lng
    ], icon: icon_to_use)

    if leaf.mapSettings['marker_message'] != ''
      map_center_marker.bindPopup(leaf.mapSettings['marker_message'] + ' - ' + item_category['item_name']).openPopup()

    markers.group.addLayer map_center_marker
    leaf.map.addLayer markers.group

    leaf.map.setView [
      leaf.my_lat
      leaf.my_lng
    ], leaf.mapSettings['zoom_level']

  return