global = this

global.Home = (locations_exact, locations_postal, locations_district, area_geocodes, marker_colors) ->
  @locations_exact = locations_exact
  @locations_postal = locations_postal
  @locations_district = locations_district
  @area_geocodes = area_geocodes
  @marker_colors = marker_colors

  @init()
  @putLocationMarkers()

Home::init = ->
  # Offcanvas related scripts
  $('[data-toggle=offcanvas]').click ->
    $('.row-offcanvas').toggleClass 'active'

  # This event replaces the 'zoomToBoundsOnClick' MarkerCluster option. When clicking on a marker cluster,
  # 'zoomToBoundsOnClick' would zoom in too much, and push the markers to the edge of the screen.
  # This event underneath fixes this behaviour, the markers are not pushed to the boundaries of the map anymore.
  if markers.group != ''
    markers.group.on 'clusterclick', (a) ->
      bounds = a.layer.getBounds().pad(0.5)
      leaf.map.fitBounds bounds

  # This is to correct a behavior that was happening in Chrome: when clicking on the zoom control panel, in the home page, the page would scroll down.
  # When clicking on zoom in/zoom out, this will force to be at the top of the page
  $('#home-map-canvas-wrapper .leaflet-control-zoom-out, #home-map-canvas-wrapper .leaflet-control-zoom-in').click ->
    $('html, body').animate { scrollTop: 0 }, 0

  # Initializing the right-hand side navigation bar, on the home page.
  navSidebar = L.control.sidebar('sidebar', position: 'right')
  leaf.map.addControl navSidebar

  
###*
# Populates the map with different markers (eg exact address and area-type markers, to show ads)
# @param locations_hash - hash containing the info to create all different markers.
###
Home::putLocationMarkers = ->
  _this = this
  # The MarkerClusterGroup object will allow to aggregate location markers (both 'exact location' and 'area' markers),
  # when they get too close to one another, as the user zooms out, on the home page.
  markers.group = new (L.MarkerClusterGroup)(
    spiderfyDistanceMultiplier: 2
    zoomToBoundsOnClick: false)

  markers.area_geocodes = _this.area_geocodes
  markers.marker_colors = _this.marker_colors
  # Displaying markers on map
  markers.place_exact_locations_markers(_this.locations_exact, false)
  # Displaying postal code area circles on map
  markers.draw_postal_code_areas(_this.locations_postal)
  # Displaying district areas on map
  markers.draw_district_areas(_this.locations_district)
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

  searched_location_marker = ''
  if typeof leaf.searched_address != 'undefined'
    # Adding marker for the searched address, on the home page.
    searched_location_marker = L.marker([
      leaf.my_lat
      leaf.my_lng
    ], icon: markers.default_icon).bindPopup(leaf.searched_address)
    searched_location_marker.addTo leaf.map

  # Adding all the markers to the map.
  leaf.map.addLayer markers.group
  if searched_location_marker != ''
    searched_location_marker.openPopup()