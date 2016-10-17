global = this

global.MapSettings = ->
  @init()

MapSettings::init = ->

  find_geocodes()

  $('.leaflet-control-zoom-out, .leaflet-control-zoom-in').click ->
    $('html, body').animate { scrollTop: 0 }, 0

  # Setting the zoom level either from the dropdown box or from the map zoom controls.
  $('[id$=form_zoom_level]').change ->
    leaf.map.setZoom(zoomValue = $('[id$=form_zoom_level]').val())

  leaf.map.on 'zoomend', ->
    $('[id$=form_zoom_level]').val(leaf.map.getZoom())

  # Refreshing map, when "Map type" field is modified.
  $('.map-chosen-list, .mapbox-name-list').change ->
    selected_map = ''
    $('select option:selected').each ->
      map_settings['chosen_map'] = $('.map-chosen-list').val()
      if map_settings['mapbox_tile_url'] != ''
        toReplace = map_settings['mapbox_tile_url'].match("v4/(.*)/{z}")[1]
        newMapboxVal = $('.mapbox-name-list').val()
        map_settings['mapbox_tile_url'] = map_settings['mapbox_tile_url'].replace(toReplace, newMapboxVal)
      initLeafletMap(map_settings)