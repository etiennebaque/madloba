global = this

global.Home = (locations_exact, areas, marker_colors) ->
  markers.locations_exact = locations_exact
  markers.areas = areas
  markers.marker_colors = marker_colors

  @init()
  @putLocationMarkers()

Home::init = ->
  # This is to correct a behavior that was happening in Chrome: when clicking on the zoom control panel,
  # in the home page, the page would scroll down.
  # When clicking on zoom in/zoom out, this will force to be at the top of the page
  $('.leaflet-control-zoom-out, .leaflet-control-zoom-in').click ->
    $('html, body').animate { scrollTop: 0 }, 0

  # Initialize the right-hand side navigation bar, on the home page. Open it on load (not on mobile)
  L.control.sidebar('sidebar').addTo(leaf.map)
  if !$('.navbar-toggle').is(':visible')
    $('#sidebar_category_icon').trigger('click')

  # After choosing an area, moves the map to where it is.
  @moveMapBasedOnArea()


###*
# Populates the map with different markers (eg exact address and area-type markers, to show ads)
# @param locations_hash - hash containing the info to create all different markers.
###
Home::putLocationMarkers = ->
  _this = this
  # The MarkerClusterGroup object will allow to aggregate location markers (both 'exact location' and 'area' markers),
  # when they get too close to one another, as the user zooms out, on the home page.
  markers.group = new (L.markerClusterGroup)(
    spiderfyDistanceMultiplier: 2)
  markers.area_group = L.featureGroup().addTo(leaf.map)

  # Displaying markers on map
  markers.place_exact_locations_markers(markers.locations_exact, false)
  markers.place_area_markers(markers.areas, false)

  # Event to trigger when click on a link in an area popup, on the home page map. Makes a modal window appear.
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

      resultModalTitle = gon.vars['ads_for'] + ' \'' + input[0].capitalizeFirstLetter() + '\' - ' + data['area_name']
      $('#adsModalTitle').html icon + resultModalTitle
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
    

Home::moveMapBasedOnArea = ->
  $('.sidebar-area-select').on('change', ->
    selectedOption = $('.sidebar-area-select option:selected')
    latitude = selectedOption.data('latitude')
    longitude = selectedOption.data('longitude')

    leaf.map.flyTo([latitude, longitude], 15, {animate: true})

  )