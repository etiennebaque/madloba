global = this

global.Home = (locations_exact, areas, params, marker_colors) ->
  markers.locations_exact = locations_exact
  markers.areas = areas
  markers.marker_colors = marker_colors

  @params = params

  @init()
  @putLocationMarkers()

Home::init = ->
  # This is to correct a behavior that was happening in Chrome: when clicking on the zoom control panel,
  # in the home page, the page would scroll down.
  # When clicking on zoom in/zoom out, this will force to be at the top of the page
  $('.leaflet-control-zoom-out, .leaflet-control-zoom-in').click ->
    $('html, body').animate { scrollTop: 0 }, 0

  # Initialize the sidebars on the home page. Open it on load (not on mobile)
  L.control.sidebar('sidebar').addTo(leaf.map)
  L.control.sidebar('search_result', {position: 'right'}).addTo(leaf.map)
  
  if !$('.navbar-toggle').is(':visible')
    $('#sidebar_category_icon').trigger('click')

  # After choosing an area, moves the map to where it is.
  leaf.moveMapBasedOnArea({showAreaIcon: true, zoom: 15})


  global.navState.populateSearchResultsSidebar()

  # Update left sidebar with info related to url params
  global.navState.applyQueryParams(@params)

  # Ajax calls made when choosing a category, in the sidebar.
  @refineMarkers()

  # Update left sidebar height()
  updateCategorySidebarHeight()


###*
# Populates the map with different markers (eg exact address and area-type markers, to show posts)
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

  # Creating area markers and registering them (showing one area marker at a time when area selected in the sidebar)
  markers.registerAreaMarkers(markers.areas, false)


  searched_location_marker = ''
  if typeof leaf.searched_address != 'undefined'
    # Adding marker for the searched address, on the home page.
    searchedLocationMarker = L.marker([
      leaf.my_lat
      leaf.my_lng
    ], icon: markers.default_icon)

    popup = L.popup().setContent(leaf.searched_address)

    searchedLocationMarker.bindPopup popup
    searchedLocationMarker.addTo leaf.map
    searchedLocationMarker.openPopup()
    leaf.map.flyTo([leaf.my_lat, leaf.my_lng], 15, {animate: true})

  # Adding all the markers to the map.
  leaf.map.addLayer markers.group

  if searched_location_marker != ''
    searched_location_marker.openPopup()


Home::refineMarkers = ->
  _this = this
  $('#sidebar').on 'click', '.guided-nav-category', ->
    # Copying the html of the selected category
    # and inserting it in the "Selected categories" section.
    selectedLinkHtml = $(this).clone()
    link_id = $(this).attr('id')
    if global.navState.cat.indexOf(link_id) > -1
      # User is removing this category from the "Your selection" section.
      selectedLinkHtml.find('i.align-cross').remove()
      $('#available_categories').append selectedLinkHtml.prop('outerHTML')
      # Deleting the html of the selected category in initial list.
      $(this).remove()
      global.navState.cat = jQuery.grep(global.navState.cat, (value) ->
        value != link_id
      )
      if global.navState.cat.length == 0
        $('#refinements').html ''
    else
      # User is selecting this category to refine their search.

      if global.navState.cat.length == 0
        $('#refinements h5').removeClass('hide')

      selectedLinkHtml.append '<i class=\'glyphicon glyphicon-remove align-cross\' style=\'float: right;\'></i>'
      $('#refinements').append selectedLinkHtml.prop('outerHTML')

      # Deleting the html of the selected category in initial list.
      $(this).remove()
      global.navState.cat.push $(this).attr('id')

    global.navState.getMarkersFromNavState()

