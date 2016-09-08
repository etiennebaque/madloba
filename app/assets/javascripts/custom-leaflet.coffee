# Using this root context variable to define global variables later on.
global = this

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
  districts: null
  searched_address: ''

  init: (map_settings) ->
    if map_settings['chosen_map'] == 'mapbox'
      L.mapbox.accessToken = map_settings['mapbox_api_key']
      leaf.map = L.mapbox.map('map', map_settings['mapbox_map_name'], scrollWheelZoom: false)
    else
      leaf.map = L.map('map', scrollWheelZoom: false)

    leaf.map.on 'click', ->
      if leaf.map.scrollWheelZoom.enabled()
        leaf.map.scrollWheelZoom.disable()
      else
        leaf.map.scrollWheelZoom.enable()
      return
    leaf.my_lat = map_settings['latitude']
    leaf.my_lng = map_settings['longitude']
    leaf.searched_address = map_settings['searched_address']
    if map_settings['chosen_map'] == 'open_street_map'
      leaf.map_tiles = L.tileLayer(map_settings['tiles_url'], attribution: map_settings['attribution'])
      leaf.map_tiles.addTo leaf.map
    else if map_settings['chosen_map'] == 'map_quest'
      # Mapquest
      leaf.map_tiles = MQ.mapLayer()
      leaf.map_tiles.addTo leaf.map


    leaf.map.setView [
      leaf.my_lat
      leaf.my_lng
    ], map_settings['zoom_level']
    # Load districts when available (eg. on area settings page, when all of them need to show up on a map...)
    if typeof districts != 'undefined' and districts != null
      leaf.districts = districts
    return

  show_features_on_ad_details_page: (map_settings) ->
    if map_settings['ad_show_is_area'] == true
      # Postal or district address (area type).
      # Shows an area icon on the map of the ads show page.
      if map_settings['loc_type'] == 'district'
        # Drawing the district related to this ad.
        district_latlng = leaf.show_single_district(map_settings['popup_message'], map_settings['bounds'])
        leaf.map.setView district_latlng, map_settings['zoom_level']
      else
        # Drawing the postal code area circle related to this ad.
        area = new (L.circle)([
          leaf.my_lat
          leaf.my_lng
        ], 600,
          color: markers.postal_code_area_color
          fillColor: markers.postal_code_area_color
          fillOpacity: 0.3)
        area.addTo(leaf.map).bindPopup(map_settings['popup_message']).openPopup()
        leaf.map.setView [
          leaf.my_lat
          leaf.my_lng
        ], map_settings['zoom_level']
    else
      # Exact address. Potentially several center markers on the map.
      # Displays a marker for each item tied to the ad we're showing the details of.
      # Using the Marker Cluster plugin to spiderfy this ad's item marker.
      markers.group = new (L.MarkerClusterGroup)(
        spiderfyDistanceMultiplier: 2
        zoomToBoundsOnClick: false)
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
    if map_settings['loc_type'] == 'postal'
      # Drawing the postal code area circle related to this ad.
      markers.postal_code_circle = new (L.circle)([
        leaf.my_lat
        leaf.my_lng
      ], 600,
        color: markers.postal_code_area_color
        fillColor: markers.postal_code_area_color
        fillOpacity: 0.3)
      markers.postal_code_circle.addTo(leaf.map).bindPopup(map_settings['marker_message']).openPopup()
    else if map_settings['loc_type'] == 'district'
      leaf.show_single_district map_settings['marker_message'], map_settings['bounds']
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

  setup_custom_behaviors: (map_settings) ->
    if map_settings['clickable_map_marker'] != 'none'
      # Getting latitude and longitude of clicked point on the map.
      leaf.map.on 'click', onMapClickLocation

  show_single_district: (district_name, bounds) ->
    # Before adding the selected district, we need to remove all the currently displayed districts.
    if markers.selected_area != ''
      leaf.map.removeLayer markers.selected_area
    latlng = ''
    # Drawing the selecting district on the map.
    L.geoJson JSON.parse(bounds), onEachFeature: (feature, layer) ->
      layer.bindPopup district_name
      layer.setStyle color: markers.district_color
      leaf.map.addLayer layer
      latlng = layer.getBounds().getCenter()
      layer.openPopup latlng
      markers.selected_area = layer
      return
    latlng
    

###*
# Object gathering different markers and icons that are used on the Madloba maps.
###

global.markers =
  new_marker: ''
  selected_area: ''
  postal_code_circle: ''
  group: ''
  postal_group: ''
  district_group: ''
  default_icon: null
  new_icon: null
  marker_colors: null
  postal_code_area_color: null
  district_color: null
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
      iconAnchor: [
        12
        41
      ]
      popupAnchor: [
        0
        -34
      ])
    markers.location_marker_type = map_settings['clickable_map_marker']
    markers.district_color = map_settings['district_color']
    markers.postal_code_area_color = map_settings['postal_code_area_color']
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
          maxWidth: 300).setContent('Loading...')
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
              return
            success: (data) ->
              marker_popup.setContent data
              marker_popup.update()
              return
            error: (data) ->
              marker_popup.setContent data
              marker_popup.update()
              return
          return
        markers.group.addLayer marker
        j++
      i++
    return

  draw_postal_code_areas: (locations_postal) ->
    if locations_postal != null and Object.keys(locations_postal).length > 0
      markers.postal_group = L.featureGroup().addTo(leaf.map)
      # Adding event to show/hide these districts from the checkbox in the guided navigation.
      $('#show_area_id').change(->
        if $('#show_area_id').prop('checked')
          # Drawing districts in this function, when checkbox is checked.
          drawPostalCodeAreaOnMap locations_postal
        else
          markers.postal_group.eachLayer (layer) ->
            markers.postal_group.removeLayer layer
            return
        return
      ).change()
    return

  draw_district_areas: (locations_district) ->
    # Snippet that creates markers, to represent ads tied to district-type location.
    if locations_district != null and Object.keys(locations_district).length > 0
      markers.district_group = L.featureGroup().addTo(leaf.map)
      # Adding event to show/hide these districts from the checkbox in the guided navigation.
      $('#show_area_id').change(->
        if $('#show_area_id').prop('checked')
          # Drawing districts in this function, when checkbox is checked.
          drawDistrictsOnMap locations_district
        else
          markers.district_group.eachLayer (layer) ->
            markers.district_group.removeLayer layer
            return
        return
      ).change()
    return

# Adding capitalization of first word of a string to String prototype.
# Used to capitalize item names, in marker popup and area modal windows.

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
    if map_settings['ad_show']
      # Showing markers, district area or postal code area on the ad details page (ads#show)
      leaf.show_features_on_ad_details_page map_settings
    else
      # Center single marker on the map
      # Appearing only in admin map setting, and admin location page, on page load.
      # Define first if it should be the area icon (for addresses based only on postal codes), or the default icon.
      leaf.show_single_marker map_settings
  # Depending of the page, the map might react differently (eg. marker showing on onClick...)
  # This method sets up the map behavior in relation to the page the user's on.
  leaf.setup_custom_behaviors map_settings
  return

###*
# Populates the map with different markers (eg exact address and area-type markers, to show ads)
# @param locations_hash - hash containing the info to create all different markers.
###

global.putLocationMarkers = (locations_exact, locations_postal, locations_district, area_geocodes, marker_colors) ->
  # The MarkerClusterGroup object will allow to aggregate location markers (both 'exact location' and 'area' markers),
  # when they get too close to one another, as the user zooms out, on the home page.
  markers.group = new (L.MarkerClusterGroup)(
    spiderfyDistanceMultiplier: 2
    zoomToBoundsOnClick: false)
  markers.area_geocodes = area_geocodes
  markers.marker_colors = marker_colors
  # Displaying markers on map
  markers.place_exact_locations_markers locations_exact, false
  # Displaying postal code area circles on map
  markers.draw_postal_code_areas locations_postal
  # Displaying district areas on map
  markers.draw_district_areas locations_district
  # Event to trigger when click on a link in a area popup, on the home page map. Makes a modal window appear.
  # Server side is in home_controller, method showSpecificAds.
  $('#map').on 'click', '.area_link', ->
    input = $(this).attr('id').split('|')
    $.get '/showSpecificAds', {
      item: input[0]
      type: input[1]
      area: input[2]
    }, (data) ->
      html_to_append = '<ul>'
      i = 0
      while i < data['ads'].length
        ad = data['ads'][i]
        html_to_append = html_to_append + '<li><a href="/ads/' + ad['id'] + '/">' + ad['title'] + '</a></li>'
        i++
      html_to_append = html_to_append + '</ul>'
      $('#ads-modal-body-id').html html_to_append
      icon = ''
      if typeof data['icon'] != 'undefined'
        icon = '<i class="fa ' + data['icon'] + '" style="color: ' + data['hexa_color'] + '; padding-right: 10px;"></i>'
      $('#adsModalTitle').html icon + gon.vars['ads_for'] + ' \'' + input[0].capitalizeFirstLetter() + '\' - ' + data['area_name']
      options =
        'backdrop': 'static'
        'show': 'true'
      $('#adsModal').modal options
      return
    return
  searched_location_marker = ''
  if typeof leaf.searched_address != 'undefined'
    # Adding marker for the searched address, on the home page.
    searched_location_marker = L.marker([
      leaf.my_lat
      leaf.my_lng
    ], icon: markers.default_icon).bindPopup(leaf.searched_address)
    searched_location_marker.addTo leaf.map
    #markers.group.addLayer(searched_location_marker);
    #leaf.map.fitBounds(markers.group.getBounds().pad(0.1));
  # Adding all the markers to the map.
  leaf.map.addLayer markers.group
  if searched_location_marker != ''
    searched_location_marker.openPopup()
  return

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
  popup_item_name = '<span style=\'color:' + marker_colors[item['category']['marker_color']] + '\';><strong>' + item['name'].capitalizeFirstLetter() + '</strong></span>'
  if ad['is_giving'] == true
    second_sentence = gon.vars['items_given'] + '<br />' + popup_item_name + ': ' + popup_ad_link + '<br />'
  else
    second_sentence = gon.vars['items_searched'] + '<br />' + popup_item_name + ': ' + popup_ad_link + '<br />'
  if ad['image']['thumb']['url'] != null and ad['image']['thumb']['url'] != ''
    # Popup is created with a thumbnail image in it.
    ad_image = '<img class=\'thumb_ad_image\' onError="$(\'.thumb_ad_image\').remove(); $(\'.image_notification\').html(\'<i>' + gon.vars['image_not_available'] + '</i>\');" src=\'' + ad['image']['thumb']['url'] + '\'><span class="image_notification"></span>'
    result = '<div style=\'overflow: auto;\'><div class=\'col-sm-6\'>' + first_sentence + '</div><div class=\'col-sm-6\'>' + ad_image + '</div><div class=\'col-sm-12\'><br>' + second_sentence + '</div></div>'
  else
    # Popup is created without any thumbnail image.
    result = '<div style=\'overflow: auto;\'>' + first_sentence + '<br><br>' + second_sentence + '</div>'
  result

###*
# This function draws districts (where at least one current ad is included)
# on the map of the home page.
###

global.drawDistrictsOnMap = (locations_district) ->
  Object.keys(locations_district).forEach (district_id) ->
    locations = locations_district[district_id]
    district_name = markers.area_geocodes[district_id]['name']
    district_bounds = markers.area_geocodes[district_id]['bounds']
    popup_html_text = createPopupHtmlArea(gon.vars['in_this_district'] + ' (<b>' + district_name + '</b>)<br /><br />', locations, 'district', district_id)
    # Adding the districts (which have ads) to the home page map.
    L.geoJson JSON.parse(district_bounds), onEachFeature: (feature, layer) ->
      layer.bindPopup popup_html_text
      layer.setStyle color: markers.district_color
      markers.district_group.addLayer layer
      return
    return
  return

###*
# This function draws postal code areas (where at least a current ad is included)
# on the map of the home page.
###

global.drawPostalCodeAreaOnMap = (locations_postal) ->
  Object.keys(locations_postal).forEach (area_code) ->
    locations = locations_postal[area_code]
    popup_html_text = createPopupHtmlArea('In this area (<b>' + area_code + '</b>)<br /><br />', locations, 'postal', area_code)
    area = L.circle([
      markers.area_geocodes[area_code]['latitude']
      markers.area_geocodes[area_code]['longitude']
    ], 600,
      color: markers.postal_code_area_color
      fillColor: markers.postal_code_area_color
      fillOpacity: 0.3).bindPopup(popup_html_text)
    markers.postal_group.addLayer area
    return
  return

###*
# Creates the text to be shown in a marker popup,
# giving details about the selected area-type location (postal or district).
# @param first_sentence
# @param location
# @returns Popup text content.
###

createPopupHtmlArea = (first_sentence, locations_from_same_area, area_type, area_id) ->
  is_giving_item = false
  is_accepting_item = false
  # Adding a explanatory note, before listing items
  explanation = '<i>' + gon.vars['select_item'] + '</i><br /><br />'
  first_sentence = first_sentence + explanation
  people_give = gon.vars['items_given'] + '<br />'
  people_accept = gon.vars['items_searched'] + '<br />'
  # This hash will count how many ads we have, per promoted item.
  ad_number_per_item = {}
  # This array will be used to sort items alphabetically.
  sorted_items = []
  i = 0
  while i < locations_from_same_area.length
    location = locations_from_same_area[i]
    j = 0
    while j < location['ads'].length
      ad = location['ads'][j]
      k = 0
      while k < ad['items'].length
        item = ad['items'][k]
        item_marker_color = item['name'] + '|' + markers.marker_colors[item['category']['marker_color']]
        if item_marker_color of ad_number_per_item
          ad_number_per_item[item_marker_color]['number'] = ad_number_per_item[item_marker_color]['number'] + 1
        else
          ad_number_per_item[item_marker_color] = {}
          ad_number_per_item[item_marker_color]['number'] = 1
          ad_number_per_item[item_marker_color]['is_giving'] = ad['is_giving']
          sorted_items.push item_marker_color
        k++
      j++
    i++
  # We now sort all the items we worked with right above (they are appended with marker colors, but still, items get sorted).
  sorted_items = sorted_items.sort()
  # Popup for this area is created here.
  idx = 0
  while idx < sorted_items.length
    this_marker_color = sorted_items[idx]
    item_info = this_marker_color.split('|')
    item_name = item_info[0]
    marker_color = item_info[1]
    number_of_ads = ad_number_per_item[this_marker_color]['number']
    popup_item_name = '<span style=\'color:' + marker_color + ';\' >' + item_name.capitalizeFirstLetter() + '</span>'
    link_id = item_name + '|' + area_type + '|' + area_id
    popup_ad_link = '- <a href=\'#\' class=\'area_link\' id=\'' + link_id + '\'>' + popup_item_name + ' (' + number_of_ads + ')</a>'
    if ad_number_per_item[this_marker_color]['is_giving'] == true
      is_giving_item = true
      people_give = people_give + popup_ad_link + '<br />'
    else
      is_accepting_item = true
      people_accept = people_accept + popup_ad_link + '<br />'
    idx++
  # Putting all the sections of the popup together.
  if !is_giving_item and is_accepting_item
    first_sentence = first_sentence + people_accept
  else if !is_accepting_item and is_giving_item
    first_sentence = first_sentence + people_give
  else
    first_sentence = first_sentence + people_give + '<br />' + people_accept
  first_sentence

###*
# This method initialize the right-hand side navigation bar, on the home page.
###
global.initializeSideBar = (sidebar) ->
  # Side bar is shown, right before initializing it, after map is fully loaded.
  navSidebar = L.control.sidebar('sidebar', position: 'right')
  leaf.map.addControl navSidebar


###*
# Defines latitude and longitude, after a click on a map (eg on map settings page...).
# Updates hidden fields, if needed, if the geocodes are part of a form.
###

onMapClickLocation = (e) ->
  new_geocodes = onMapClick(e)
  geocodeSplit = new_geocodes.split(',')

  # latitude and longitude are classes used on area settings page.
  $('#new_dynamic_button_add').removeClass 'disabled'
  $('.latitude').val geocodeSplit[0]
  $('.longitude').val geocodeSplit[1]
  return

###*
# Callback function that returns geocodes of clicked location.
# @param e
# @returns "latitude,longitude"
###

onMapClick = (e) ->
  if markers.new_marker != ''
    leaf.map.removeLayer markers.new_marker
  if markers.postal_code_circle != ''
    leaf.map.removeLayer markers.postal_code_circle
  myNewLat = e.latlng.lat
  myNewLng = e.latlng.lng
  # Rounding up latitude and longitude, with 5 decimals
  myNewLat = Math.round(myNewLat * 100000) / 100000
  myNewLng = Math.round(myNewLng * 100000) / 100000
  if markers.location_marker_type == 'exact'
    markers.new_marker = new (L.Marker)(e.latlng, { icon: markers.new_icon }, draggable: false)
    leaf.map.addLayer markers.new_marker
  else if markers.location_marker_type == 'area'
    markers.postal_code_circle = new (L.circle)(e.latlng, 600,
      color: markers.postal_code_area_color
      fillColor: markers.postal_code_area_color
      fillOpacity: 0.3)
    markers.postal_code_circle.addTo leaf.map
  myNewLat + ',' + myNewLng

String::capitalizeFirstLetter = ->
  @charAt(0).toUpperCase() + @slice(1)
