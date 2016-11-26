global = this

global.AreaSettings = (areas) ->
  @area_bounds = {}
  @layer = {}
  @init(areas)

# Adding specific events on the 'Area settings' page,
# needed when drawing and saving areas.
AreaSettings::init = (areas) ->
  markers.areas = areas

  @onMapClick()
  @drawMapAndAreaMarkers()
  @initMapEvents()

#  @drawMapAndAreas()
#  @initMapEvents()
#  @initDrawingTools()


AreaSettings::drawMapAndAreaMarkers = ->
  if markers.areas != null
  # Adding existing areas to the map
    for area in markers.areas
      marker = L.marker(
        [area.latitude, area.longitude],
        icon: markers.area_icon,
        bounceOnAdd: false
      )

      popupContent = "<div class='area-popup-text'>" + @areaNameFor(area) + @modifyButtonFor(area) + @deleteButtonFor(area) + "</div>"
      editContent = "<div class='area-popup-update' style='display: none;'>" + @inputTextFor(area) + @okButtonFor(area) + "</div>"

      popup = L.popup().setContent(popupContent + editContent)
      marker.bindPopup popup, popupOptions({minWidth: 200})

      marker.addTo(leaf.map)

AreaSettings::areaNameFor = (area) ->
  "<div class='area-name'>#{area.name}</div>"

AreaSettings::inputTextFor = (area) ->
  "<input type='text' id='#{area.id}' " +
    "class='update-area-text name_#{area.id}' style='margin-right:5px;' placeholder='Area name' " +
    "value='#{area.name}'>"

AreaSettings::modifyButtonFor = (area) ->
  "<button type='button' id='update_#{area.id}' " +
    "class='btn btn-xs btn-info update-area'><i class='fa fa-pencil' aria-hidden='true'></i></button>"

AreaSettings::okButtonFor = (area) ->
  "<button type='button' id='save_#{area.id}' " +
    "data-lat='#{area.latitude}' data-lng='#{area.longitude}' " +
    "class='btn btn-xs btn-success save-area'>OK</button>&nbsp;"

AreaSettings::deleteButtonFor = (area) ->
  "<button type='button' id='delete_#{area.id}' " +
    "class='btn btn-xs btn-danger delete-area'><i class='fa fa-trash-o' aria-hidden='true'></i></button>"

AreaSettings::initMapEvents = ->
  $('#map').on 'keyup', '.update-area-text', ->
    if $('.update-area-text').val().length > 0
      $('.save-area').removeClass 'disabled'
    else
      $('.save-area').addClass 'disabled'

  # Necessity to unbind click on map, to make
  # the "on click" event right below work.
  $('#map').unbind 'click'

  # Showing the input text box (Edit mode)
  $('#map').on 'click', '.update-area', (e) ->
    $('#area_notification_message').html('')
    _this = $(this)
    _this.parent().hide()
    _this.parent().next().show()

  # Saving area location and name.
  $('#map').on 'click', '.save-area', (e) ->
    _this = $(this)

    areaId = _this.attr('id').replace('save_', '')
    areaName = $('.name_'+areaId).val()

    $.post '/user/areasettings/save_area', {
      id: areaId
      name: areaName
      latitude: _this.data('lat')
      longitude: _this.data('lng')
    }, (data) ->
      msg = '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
      $('#area_notification_message').html msg
      _this.parent().hide()
      _this.parent().prev().show()
      _this.parent().prev().find('.area-name').html(data.name)


  $('#map').on 'click', '.delete-area', ->
    _this = $(this)
    areaId = _this.attr('id').replace('delete_', '')

    $.post '/user/areasettings/delete_areas', { id: areaId }, (data) ->
      msg = '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
      $('#area_notification_message').html msg


AreaSettings::onMapClick = ->
  leaf.map.on 'click', (e) =>
    geocodes = initMapClick(e)
    markers.new_marker = new (L.Marker)(e.latlng, { icon: markers.area_icon }, draggable: false)
    leaf.map.addLayer markers.new_marker
    newArea = {id: 'new', name: '', latitude: geocodes['lat'], longitude: geocodes['lng']}

    popupContent = "<div class='area-popup-text' style='display: none;'>" + @areaNameFor(newArea) +
      @modifyButtonFor(newArea) + @deleteButtonFor(newArea) + "</div>"
    editContent = "<div class='area-popup-update'>" + @inputTextFor(newArea) + @okButtonFor(newArea) + "</div>"

    popup = L.popup().setContent(popupContent + editContent)
    markers.new_marker.bindPopup(popup, popupOptions({minWidth: 200})).openPopup()


####
# Old code used for area bounds and area drawing.
####
#  AreaSettings::drawMapAndAreas = ->
#    # Drawing map
#    initLeafletMap map_settings
#    leaf.drawn_items = L.featureGroup()
#    leaf.map.addLayer(leaf.drawn_items)
#
#    # Adding drawing control panel to the map
#    leaf.map.addControl(new (L.Control.Draw)(edit: featureGroup: leaf.drawn_items))
#
#    if leaf.areas != null
#      # Adding existing areas to the map
#      i = 0
#      while i < leaf.areas.length
#        # Adding the area id and name to the geoJson properties.
#        L.geoJson leaf.areas[i], onEachFeature: (feature, layer) ->
#          layer.bindPopup leaf.areas[i]['properties']['name'], popupOptions()
#          layer.setStyle color: markers.area_color
#          leaf.drawn_items.addLayer layer
#        i++
#
#
#  AreaSettings::initMapEvents = ->
#    _this = this
#    # Event to activate 'Save area' button when area name not empty.
#    $('#map').on 'keyup', '.save_area_text', ->
#      if $('.save_area_text').val().length > 0
#        $('.save_area').removeClass 'disabled'
#      else
#        $('.save_area').addClass 'disabled'
#
#    # Necessity to unbind click on map, to make
#    # the "on click" event right below work.
#    $('#map').unbind 'click'
#    # Saving area drawing (bounds) and name.
#    $('#map').on 'click', '.save_area', ->
#      area_name = $('.save_area_text').val()
#      $.post '/user/areasettings/save_area', {
#        bounds: JSON.stringify(_this.area_bounds)
#        name: area_name
#      }, (data) ->
#        msg = '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
#        $('#area_notification_message').html msg
#        if data.status == 'ok'
#          leaf.drawn_items.removeLayer _this.layer
#          _this.area_bounds['properties']['id'] = data.id
#          _this.area_bounds['properties']['name'] = area_name
#          L.geoJson _this.area_bounds, onEachFeature: (feature, layer) ->
#            layer.bindPopup area_name, popupOptions()
#            layer.setStyle color: data.area_color
#            leaf.drawn_items.addLayer layer
#
#
#    # Update area name into the GeoJSON properties hash.
#    $('#map').on 'click', '.update_area', ->
#      new_area_name = $('.update_area_text').val()
#      areaId = $('.update_area_text').attr('id')
#      $.post '/user/areasettings/update_area_name', {
#        id: areaId
#        name: new_area_name
#      }, (data) ->
#        msg = '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
#        $('#area_notification_message').html msg
#
#      # Going through the areas and checking which one to update.
#      leaf.drawn_items.eachLayer (layer) ->
#        _this.area_bounds = layer.toGeoJSON()
#        if areaId == _this.area_bounds['properties']['id']
#          layer.bindPopup '<input type=\'text\' id=\'' + areaId + '\' ' +
#              'class=\'update_area_text\' style=\'margin-right:5px;\' placeholder=\'Area name\' ' +
#              'value=\'' + new_area_name + '\'>' +
#              '<button type=\'button\' id=\'save_' + _this.area_bounds['properties']['id'] + '\' ' +
#              'class=\'btn btn-xs btn-success update_area\'>OK</button>' +
#              '<br /><div class=\'area_notif\'></div>', popupOptions()
#
#          layer.closePopup()
#
#
#  AreaSettings::initDrawingTools = ->
#    _this = this
#    # Events triggered once the polygon (area) has been drawn.
#    leaf.map.on 'draw:created', (e) ->
#      _this.layer = e.layer
#      leaf.drawn_items.addLayer _this.layer
#      # Text field and "Save area" button to show up in the popup.
#      popup = L.popup(closeButton: false).setContent('<input type=\'text\' class=\'save_area_text\' ' +
#          'style=\'margin-right:5px;\' placeholder=\'Area name\'><button type=\'button\' ' +
#          'class=\'btn btn-xs btn-success save_area disabled\'>Save area</button>')
#      _this.layer.bindPopup popup, popupOptions()
#      _this.area_bounds = _this.layer.toGeoJSON()
#      _this.layer.openPopup(_this.layer.getBounds().getCenter())
#
#    # When starting to edit an area, create new popup
#    # for each area with current name in text field.
#    leaf.map.on 'draw:editstart', (e) ->
#      leaf.drawn_items.eachLayer (layer) ->
#        _this.area_bounds = layer.toGeoJSON()
#        layer.bindPopup '<input type=\'text\' id=\'' + _this.area_bounds['properties']['id'] + '\' ' +
#            'class=\'update_area_text\' style=\'margin-right:5px;\' placeholder=\'Area name\' ' +
#            'value=\'' + _this.area_bounds['properties']['name'] + '\'>' +
#            '<button type=\'button\' id=\'save_' + _this.area_bounds['properties']['id'] + '\' ' +
#            'class=\'btn btn-xs btn-success update_area\'>OK</button><br /><div class=\'area_notif\'></div>', popupOptions()
#
#    # After saving new name of area,
#    # remove the text input and display new name as text only.
#    leaf.map.on 'draw:editstop', (e) ->
#      leaf.drawn_items.eachLayer (layer) ->
#        _this.area_bounds = layer.toGeoJSON()
#        layer.bindPopup _this.area_bounds['properties']['name'], popupOptions()
#
#    # Event triggered when polygon (area) has been edited,
#    # and "Save" has been clicked.
#    leaf.map.on 'draw:edited', (e) ->
#      layers = e.layers
#      updated_areas = []
#      layers.eachLayer (layer) ->
#        _this.area_bounds = layer.toGeoJSON()
#        updated_areas.push _this.area_bounds
#
#      $.post '/user/areasettings/update_areas', { areas: JSON.stringify(updated_areas) }, (data) ->
#        msg = '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
#        $('#area_notification_message').html msg
#
#    # Event triggered after deleting areas and clicking on 'Save'.
#    leaf.map.on 'draw:deleted', (e) ->
#      layers = e.layers
#      area_ids = []
#      layers.eachLayer (layer) ->
#        area = layer.toGeoJSON()
#        area_ids.push area['properties']['id']
#
#      $.post '/user/areasettings/delete_areas', { ids: area_ids }, (data) ->
#        msg = '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
#        $('#area_notification_message').html msg

