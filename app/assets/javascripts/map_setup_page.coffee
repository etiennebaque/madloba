global = this

global.MapSetupPage = ->
  @init()

MapSetupPage::init = ->

  leaf.map.on 'zoomend', ->
    $('[id$=form_zoom_level]').val(leaf.map.getZoom())

  find_geocodes()
  leaf.map.on 'click', onMapClickLocation
