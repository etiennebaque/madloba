global = this

global.AreaSettings = (districts) ->
  @district_bounds = {}
  @layer = {}
  @init(districts)

# Adding specific events on the 'Area settings' page,
# needed when drawing and saving districts.
AreaSettings::init = (districts) ->
  leaf.districts = districts

  # Show either the "postal code" or the "district" section.
  $('.area_postal_code').click ->
    $('#postal_code_section').toggle 0, ->

  if $('.area_postal_code').is(':checked')
    $('#postal_code_section').css 'display', 'block'

  # Show appropriate section when choosing an area
  $('.area_district').click ->
    $('#district_section').toggle 0, ->
    @drawMapAndDistricts()

  if $('.area_district').is(':checked')
    $('#district_section').css 'display', 'block'
    @drawMapAndDistricts()

  @initMapEvents()
  @initDrawingTools()


AreaSettings::drawMapAndDistricts = ->
  # Drawing map
  initLeafletMap map_settings
  leaf.drawn_items = L.featureGroup()
  leaf.map.addLayer(leaf.drawn_items)

  # Adding drawing control panel to the map
  leaf.map.addControl(new (L.Control.Draw)(edit: featureGroup: leaf.drawn_items))

  if leaf.districts != null
    # Adding existing districts to the map
    i = 0
    while i < leaf.districts.length
      # Adding the district id and name to the geoJson properties.
      L.geoJson leaf.districts[i], onEachFeature: (feature, layer) ->
        layer.bindPopup leaf.districts[i]['properties']['name']
        layer.setStyle color: markers.district_color
        leaf.drawn_items.addLayer layer
      i++


AreaSettings::initMapEvents = ->
  _this = this
  # Event to activate 'Save district' button when district name not empty.
  $('#map').on 'keyup', '.save_district_text', ->
    if $('.save_district_text').val().length > 0
      $('.save_district').removeClass 'disabled'
    else
      $('.save_district').addClass 'disabled'

  # Necessity to unbind click on map, to make
  # the "on click" event right below work.
  $('#map').unbind 'click'
  # Saving district drawing (bounds) and name.
  $('#map').on 'click', '.save_district', ->
    district_name = $('.save_district_text').val()
    $.post '/user/areasettings/save_district', {
      bounds: JSON.stringify(_this.district_bounds)
      name: district_name
    }, (data) ->
      msg = '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
      $('#district_notification_message').html msg
      if data.status == 'ok'
        leaf.drawn_items.removeLayer _this.layer
        _this.district_bounds['properties']['id'] = data.id
        _this.district_bounds['properties']['name'] = district_name
        L.geoJson _this.district_bounds, onEachFeature: (feature, layer) ->
          layer.bindPopup district_name
          layer.setStyle color: data.district_color
          leaf.drawn_items.addLayer layer


  # Update district name into the GeoJSON properties hash.
  $('#map').on 'click', '.update_district', ->
    new_district_name = $('.update_district_text').val()
    districtId = $('.update_district_text').attr('id')
    $.post '/user/areasettings/update_district_name', {
      id: districtId
      name: new_district_name
    }, (data) ->
      msg = '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
      $('#district_notification_message').html msg

    # Going through the districts and checking which one to update.
    leaf.drawn_items.eachLayer (layer) ->
      _this.district_bounds = layer.toGeoJSON()
      if districtId == _this.district_bounds['properties']['id']
        layer.bindPopup '<input type=\'text\' id=\'' + districtId + '\' ' +
            'class=\'update_district_text\' style=\'margin-right:5px;\' placeholder=\'District name\' ' +
            'value=\'' + new_district_name + '\'>' +
            '<button type=\'button\' id=\'save_' + _this.district_bounds['properties']['id'] + '\' ' +
            'class=\'btn btn-xs btn-success update_district\'>OK</button>' +
            '<br /><div class=\'district_notif\'></div>'

        layer.closePopup()


AreaSettings::initDrawingTools = ->
  _this = this
  # Events triggered once the polygon (district) has been drawn.
  leaf.map.on 'draw:created', (e) ->
    _this.layer = e.layer
    leaf.drawn_items.addLayer _this.layer
    # Text field and "Save district" button to show up in the popup.
    popup = L.popup(closeButton: false).setContent('<input type=\'text\' class=\'save_district_text\' ' +
        'style=\'margin-right:5px;\' placeholder=\'District name\'><button type=\'button\' ' +
        'class=\'btn btn-xs btn-success save_district disabled\'>Save district</button>')
    _this.layer.bindPopup popup
    _this.district_bounds = _this.layer.toGeoJSON()
    _this.layer.openPopup(_this.layer.getBounds().getCenter())

  # When starting to edit a district, create new popup
  # for each district with current name in text field.
  leaf.map.on 'draw:editstart', (e) ->
    leaf.drawn_items.eachLayer (layer) ->
      _this.district_bounds = layer.toGeoJSON()
      layer.bindPopup '<input type=\'text\' id=\'' + _this.district_bounds['properties']['id'] + '\' ' +
          'class=\'update_district_text\' style=\'margin-right:5px;\' placeholder=\'District name\' ' +
          'value=\'' + _this.district_bounds['properties']['name'] + '\'>' +
          '<button type=\'button\' id=\'save_' + _this.district_bounds['properties']['id'] + '\' ' +
          'class=\'btn btn-xs btn-success update_district\'>OK</button><br /><div class=\'district_notif\'></div>'

  # After saving new name of district,
  # remove the text input and display new name as text only.
  leaf.map.on 'draw:editstop', (e) ->
    leaf.drawn_items.eachLayer (layer) ->
      _this.district_bounds = layer.toGeoJSON()
      layer.bindPopup _this.district_bounds['properties']['name']

  # Event triggered when polygon (district) has been edited,
  # and "Save" has been clicked.
  leaf.map.on 'draw:edited', (e) ->
    layers = e.layers
    updated_districts = []
    layers.eachLayer (layer) ->
      _this.district_bounds = layer.toGeoJSON()
      updated_districts.push _this.district_bounds

    $.post '/user/areasettings/update_districts', { districts: JSON.stringify(updated_districts) }, (data) ->
      msg = '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
      $('#district_notification_message').html msg

  # Event triggered after deleting districts and clicking on 'Save'.
  leaf.map.on 'draw:deleted', (e) ->
    layers = e.layers
    district_ids = []
    layers.eachLayer (layer) ->
      district = layer.toGeoJSON()
      district_ids.push district['properties']['id']

    $.post '/user/areasettings/delete_districts', { ids: district_ids }, (data) ->
      msg = '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
      $('#district_notification_message').html msg

