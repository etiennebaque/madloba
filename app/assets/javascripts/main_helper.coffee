# Using this root context variable to define global variables later on.
global = this

$ ->
  # Show Bootstrap notify on load, when needed
  if $('body').data('message').length > 0
    createNotification($('body').data('message'), $('body').data('alert'))

###*
# Initialization of the leaf object (called 'leaf' as because of the main use of the Leaflet library :) )
# This object attributes consists of the map object, map tiles and other map-related objects.
###
global.leaf =
  map: null
  map_tiles: null
  my_lat: ''
  my_lng: ''
  drawn_items: null
  areas: null
  searched_address: ''

  init: (map_settings) ->

    leaf.map = L.map('map', scrollWheelZoom: false)

    leaf.map.on 'click', ->
      if leaf.map.scrollWheelZoom.enabled()
        leaf.map.scrollWheelZoom.disable()
      else
        leaf.map.scrollWheelZoom.enable()

    leaf.my_lat = map_settings['latitude']
    leaf.my_lng = map_settings['longitude']
    leaf.searched_address = map_settings['searched_address']

    if map_settings['chosen_map'] == 'map_quest'
      # Loading Mapquest tiles
      leaf.map_tiles = MQ.mapLayer()
    else if map_settings['chosen_map'] == 'open_street_map'
      # Loading Openstreetmap tiles
      leaf.map_tiles = L.tileLayer(map_settings['osm_tile_url'], attribution: map_settings['osm_attribution'])
    else if map_settings['chosen_map'] == 'mapbox'
      # Loading Mapbox tiles
      leaf.map_tiles = L.tileLayer(map_settings['mapbox_tile_url'], attribution: map_settings['mapbox_attribution'])

    leaf.map_tiles.addTo leaf.map
    leaf.map.setView [leaf.my_lat, leaf.my_lng], map_settings['zoom_level']

    if map_settings['clickable_map_marker'] != 'none'
      # Getting latitude and longitude when map is clicked
      leaf.map.on 'click', onMapClickLocation

  show_features_on_ad_details_page: (map_settings) ->
    if map_settings['ad_show_is_area'] == true
      # Location where full address is not given (area only). Drawing the area related to this ad.
      area_latlng = leaf.show_single_area(map_settings['popup_message'], map_settings['bounds'])
      leaf.map.setView area_latlng, map_settings['zoom_level']

    else
      # Exact address. Potentially several center markers on the map.
      # Displays a marker for each item tied to the ad we're showing the details of.
      # Using the Marker Cluster plugin to spiderfy this ad's item marker.
      markers.group = new (L.markerClusterGroup)(
        spiderfyDistanceMultiplier: 2)

      i = 0
      while i < map_settings['ad_show'].length
        item_category = map_settings['ad_show'][i]
        icon_to_use = L.AwesomeMarkers.icon(
          prefix: 'fa'
          markerColor: item_category['color']
          icon: item_category['icon'])

        map_center_marker = L.marker([
          leaf.my_lat
          leaf.my_lng
        ], icon: icon_to_use)

        if map_settings['marker_message'] != ''
          map_center_marker.bindPopup(map_settings['marker_message'] + ' - ' + item_category['item_name']).openPopup()

        markers.group.addLayer map_center_marker
        i++

      leaf.map.addLayer markers.group

      leaf.map.setView [
        leaf.my_lat
        leaf.my_lng
      ], map_settings['zoom_level']

    return

  show_single_marker: (map_settings) ->
    if map_settings['loc_type'] == 'area'
      leaf.show_single_area map_settings['marker_message'], map_settings['bounds']
    else
      # we are displaying the center point.
      center_marker = L.marker([
        leaf.my_lat
        leaf.my_lng
      ], icon: markers.default_icon)
      if map_settings['marker_message'] != ''
        center_marker.addTo(leaf.map).bindPopup(map_settings['marker_message']).openPopup()
      else
        center_marker.addTo leaf.map
    return


  show_single_area: (area_name, bounds) ->
    # Before adding the selected area, we need to remove all the currently displayed areas.
    if markers.selected_area != ''
      leaf.map.removeLayer markers.selected_area
    latlng = ''
    # Drawing the selecting area on the map.
    L.geoJson JSON.parse(bounds), onEachFeature: (feature, layer) ->
      latlng = layer.getBounds().getCenter()
      popup_options = {className: 'area-popup'}
      layer.bindPopup area_name, popup_options

      layer.setStyle color: markers.area_color
      leaf.map.addLayer layer
      leaf.map.fitBounds(layer.getBounds())
      markers.selected_area = layer

    latlng
    

###*
# Object gathering different markers and icons that are used on the Madloba maps.
###
global.markers =
  new_marker: ''
  selected_area: ''
  group: ''
  postal_group: ''
  area_group: ''
  default_icon: null
  new_icon: null
  marker_colors: null
  area_color: null
  area_geocodes: null
  location_marker_type: null
  center_marker: null
  init: (map_settings) ->
    markers.default_icon = L.icon(
      iconUrl: map_settings['default_marker_icon']
      iconAnchor: [
        12
        41
      ]
      popupAnchor: [
        0
        -34
      ])
    markers.new_icon = L.icon(
      iconUrl: map_settings['new_marker_icon']
      iconAnchor: [12, 41]
      popupAnchor: [0, -34])
    markers.location_marker_type = map_settings['clickable_map_marker']
    markers.area_color = map_settings['area_color']
    return

  place_exact_locations_markers: (locations_exact, is_bouncing_on_add) ->
    i = 0
    while i < locations_exact.length
      ad = locations_exact[i]
      j = 0
      while j < ad['markers'].length
        item = ad['markers'][j]
        # Creating the marker for this ad here.
        marker_icon = L.AwesomeMarkers.icon(
          prefix: 'fa'
          markerColor: item['color']
          icon: item['icon'])

        marker = L.marker([
          ad['lat']
          ad['lng']
        ],
          icon: marker_icon
          bounceOnAdd: is_bouncing_on_add)

        marker.ad_id = ad['ad_id']
        marker.item_id = item['item_id']
        popup = L.popup(
          minWidth: 250
          maxWidth: 280).setContent('Loading...')
        marker.bindPopup popup
        # When a marker is clicked, an Ajax call is made to get the content of the popup to display
        marker.on 'click', (e) ->
          marker_popup = e.target.getPopup()
          $.ajax
            url: '/showAdPopup'
            global: false
            type: 'GET'
            data:
              ad_id: @ad_id
              item_id: @item_id
            dataType: 'html'
            beforeSend: (xhr) ->
              xhr.setRequestHeader 'Accept', 'text/html-partial'
            success: (data) ->
              marker_popup.setContent data
              marker_popup.update()
              adjustPopupPosition(marker_popup, 'exact')
            error: (data) ->
              marker_popup.setContent data
              marker_popup.update()
          return

        markers.group.addLayer marker
        j++
      i++
    return

  place_area_markers: (location_areas) ->
    Object.keys(locations_area).forEach (area_id) ->
      area_bounds = markers.area_geocodes[area_id]['bounds']
      L.geoJson JSON.parse(area_bounds), onEachFeature: (feature, layer) ->
      # Adding area marker
        marker_icon = L.icon({
          iconUrl: area_marker
          popupAnchor: [17,2]
        })
      
        marker = L.marker(
          layer.getBounds().getCenter(),
          icon: marker_icon,
          bounceOnAdd: false)

        popup = L.popup().setContent('Loading...')
        marker.bindPopup popup

        marker.on 'click', (e) ->
          marker_popup = e.target.getPopup()
          $.ajax
            url: '/showAreaPopup'
            global: false
            type: 'GET'
            data:
              area_id: area_id
              area_marker: true
            dataType: 'html'
            beforeSend: (xhr) ->
              xhr.setRequestHeader 'Accept', 'text/html-partial'
            success: (data) ->
              marker_popup.setContent data
              marker_popup.update()
              adjustPopupPosition(marker_popup, 'area')
            error: (data) ->
              marker_popup.setContent data
              marker_popup.update()
          return

        markers.group.addLayer marker
      
        return
      return
    return  


  draw_area_areas: (locations_area) ->
    # Snippet that creates markers, to represent ads tied to area-type location.
    if locations_area != null and Object.keys(locations_area).length > 0
      drawAreasOnMap(locations_area)

    return

###*
# Main function that initializes the map on different screens (eg home page, map setting page, ad page...).
# @param map_settings - hash that contains all info needed to initialize the map.
###

global.initLeafletMap = (map_settings) ->
  if leaf != null and leaf.map != null
    leaf.map.remove()

  # Initialization of the map and markers.
  leaf.init map_settings
  markers.init map_settings

  if map_settings['has_center_marker'] == true
    if $('#show_ad_page').length > 0
      # Showing markers or an area on the ad details page (ads#show)
      leaf.show_features_on_ad_details_page map_settings
    else
      # Center single marker on the map
      # Appearing only in admin map setting, and admin location page, on page load.
      # Define first if it should be the area icon (for addresses based only on postal codes), or the default icon.
      leaf.show_single_marker map_settings


###*
# This function draws areas (where at least one current ad is included)
# on the map of the home page.
###
global.drawAreasOnMap = (locations_area) ->
  Object.keys(locations_area).forEach (area_id) ->
    locations = locations_area[area_id]
    area_name = markers.area_geocodes[area_id]['name']
    area_bounds = markers.area_geocodes[area_id]['bounds']

    # Adding the areas (which have ads) to the home page map.
    areaLayer = L.geoJson JSON.parse(area_bounds), onEachFeature: (feature, layer) ->
      layer.setStyle color: markers.area_color
      markers.area_group.addLayer layer
      return

    popup_options = {className: 'area-popup'}

    areaLayer.on 'click', (e) ->
      _layer = e.layer
      $.ajax
        url: '/showAreaPopup'
        global: false
        type: 'GET'
        data:
          area_id: area_id
          area_marker: false
        dataType: 'html'
        beforeSend: (xhr) ->
          _layer.bindPopup 'Loading...', popup_options
          _layer.openPopup()
          xhr.setRequestHeader 'Accept', 'text/html-partial'
        success: (data) ->
          _layer.unbindPopup()
          _layer.bindPopup data
          markers.area_group.addLayer _layer
          _layer.off('click')
          _layer.openPopup()
          adjustPopupPosition(_layer.getPopup(), 'area')
        error: (data) ->
          _layer.unbindPopup()
          _layer.bindPopup data
          _layer.openPopup()
    return
  return


###*
# Defines latitude and longitude, after a click on a map (eg on map settings page...).
# Updates hidden fields, if needed, if the geocodes are part of a form.
###
global.onMapClickLocation = (e) ->
  new_geocodes = onMapClick(e)
  geocodeSplit = new_geocodes.split(',')

  # latitude and longitude are classes used on area settings page.
  $('#new_dynamic_button_add').removeClass 'disabled'
  $('.latitude').val geocodeSplit[0]
  $('.longitude').val geocodeSplit[1]


# Event triggered when click on "Locate me on the map" button,
# on the "Create ad" form, and on the Ad edit form.
global.find_geocodes = ->
  $('#find_geocodes_from_address').button().click ->
    location_type = 'exact'
      
    # Ajax call to get geocodes (latitude, longitude) of an exact location defined by address, postal code, city...
    # This call is triggered by "Find this city", "Find this general location" buttons,
    # on Map settings page, location edit page, map setup page...
    $.ajax
      url: '/getCityGeocodes'
      global: false
      type: 'GET'
      data:
        street_number: $('.location_streetnumber').val()
        address: $('.location_streetname').val()
        city: $('.location_city').val()
        province: $('.location_state').val()
        country: $('.location_country').val()
      cache: false
      beforeSend: (xhr) ->
        xhr.setRequestHeader 'Accept', 'application/json'
        xhr.setRequestHeader 'Content-Type', 'application/json'
        $('#findGeocodeLoaderId').html gon.vars['searching_location']
        return
      success: (data) ->
        if data != null and data.status == 'ok'
          # Geocodes were found: the location is shown on the map.
          myNewLat = Math.round(data.lat * 100000) / 100000
          myNewLng = Math.round(data.lon * 100000) / 100000
          $('.latitude').val myNewLat
          $('.longitude').val myNewLng
          # Update the center of map, to show the general area
          leaf.map.setView new (L.LatLng)(myNewLat, myNewLng), data.zoom_level
        else
          # The address' geocodes were not found - the user has to pinpoint the location manually on the map.
          $('#myErrorModal').modal 'show'
        # Displaying notification about location found.
        $('#findGeocodeLoaderId').html '<i>' + data.address_found + '</i>'


# This event replaces the 'zoomToBoundsOnClick' MarkerCluster option. When clicking on a marker cluster,
# 'zoomToBoundsOnClick' would zoom in too much, and push the markers to the edge of the screen.
# This event underneath fixes this behaviour, the markers are not pushed to the boundaries of the map anymore.
global.spiderifyMarkerGroups = ->
  if markers.group != ''
    markers.group.on 'clusterclick', (a) ->
      bounds = a.layer.getBounds().pad(0.5)
      leaf.map.fitBounds bounds


# Notification
global.createNotification = (message, alert) ->
  $.notify message,
    offset:
      x: 10
      y: 60
    type: alert
    placement:
      from: 'top'
      align: 'right'

# Center popup based on its content, by positioning the clicked maker correctly.
global.adjustPopupPosition = (popup, popup_type) ->
  console.log(popup)
  px = leaf.map.project(popup.getLatLng())
  offset = 0
  if popup_type == 'exact'
    offset = 100
  px.y -= popup._container.clientHeight/2 + offset
  if !$('.sidebar').hasClass('collapsed')
    px.x -= 140
  leaf.map.panTo(leaf.map.unproject(px),{animate: true})


###*
# Creates the text to be shown in a marker popup, giving details about the selected exact location.
# @param first_sentence
# @param location
# @returns Popup text content.
###
createPopupHtml = (first_sentence, ad, index) ->
  second_sentence = ''
  result = ''
  item = ad['items'][index]
  popup_ad_link = '<a href=\'/ads/' + ad['id'] + '/\'>' + ad['title'] + '</a>'
  markerColor = marker_colors[item['category']['marker_color']]
  itemName = item['name'].capitalizeFirstLetter()
  popup_item_name = '<span style=\'color:' + markerColor + '\';><strong>' + itemName + '</strong></span>'
  if ad['giving'] == true
    second_sentence = gon.vars['items_given'] + '<br />' + popup_item_name + ': ' + popup_ad_link + '<br />'
  else
    second_sentence = gon.vars['items_searched'] + '<br />' + popup_item_name + ': ' + popup_ad_link + '<br />'
  if ad['image']['thumb']['url'] != null and ad['image']['thumb']['url'] != ''
    # Popup is created with a thumbnail image in it.
    ad_image = '<img class=\'thumb_ad_image\' onError="$(\'.thumb_ad_image\').remove(); ' +
      '$(\'.image_notification\').html(\'<i>' + gon.vars['image_not_available'] + '</i>\');" src=\'' +
      ad['image']['thumb']['url'] + '\'><span class="image_notification"></span>'

    result = '<div style=\'overflow: auto;\'><div class=\'col-sm-6\'>' + first_sentence + '</div>' +
        '<div class=\'col-sm-6\'>' + ad_image + '</div><div class=\'col-sm-12\'><br>' +
        second_sentence + '</div></div>'

  else
    # Popup is created without any thumbnail image.
    result = '<div style=\'overflow: auto;\'>' + first_sentence + '<br><br>' + second_sentence + '</div>'
  result


###*
# Callback function that returns geocodes of clicked location.
# @param e
# @returns "latitude,longitude"
###
onMapClick = (e) ->
  if markers.new_marker != ''
    leaf.map.removeLayer markers.new_marker

  myNewLat = e.latlng.lat
  myNewLng = e.latlng.lng
  # Rounding up latitude and longitude, with 5 decimals
  myNewLat = Math.round(myNewLat * 100000) / 100000
  myNewLng = Math.round(myNewLng * 100000) / 100000
  
  if markers.location_marker_type == 'exact'
    markers.new_marker = new (L.Marker)(e.latlng, { icon: markers.new_icon }, draggable: false)
    leaf.map.addLayer markers.new_marker

  myNewLat + ',' + myNewLng

String::capitalizeFirstLetter = ->
  @charAt(0).toUpperCase() + @slice(1)
