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
  $('#map_settings_form_chosen_map').change ->
    selected_map = ''
    $('select option:selected').each ->
      map_settings['chosen_map'] = $(this).val()
      initLeafletMap(map_settings)