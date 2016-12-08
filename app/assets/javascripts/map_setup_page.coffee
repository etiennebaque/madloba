global = this

global.MapSetupPage = ->
  @init()

MapSetupPage::init = ->

  find_geocodes()
  leaf.map.on 'click', onMapClickLocation
