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

AreaSettings::drawMapAndAreaMarkers = ->
  if markers.areas != null
  # Adding existing areas to the map
    for area in markers.areas
      @initMarkerAndAddToMap(area)


AreaSettings::initMarkerAndAddToMap = (area) ->
  marker = L.marker(
    [area.latitude, area.longitude],
    icon: markers.area_icon,
    bounceOnAdd: false
  )

  popupContent = "<div class='area-popup-text'>" + @areaNameFor(area) + @modifyButtonFor(area) + @deleteButtonFor(area) + "</div>"
  editContent = "<div class='area-popup-update' style='display: none;'>" + @inputTextFor(area) + @okButtonFor(area) + "</div>"

  popup = L.popup().setContent(popupContent + editContent)
  marker.bindPopup popup, popupOptions({minWidth: 200})

  markers.area_markers[area.id] = marker

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
      $('#area_notification_message').html(' ')
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
  $('#map').on 'click', '.save-area', (e) =>
    self = this
    _this = $('.save-area:visible')

    areaId = _this.attr('id').replace('save_', '')
    areaName = $('.name_'+areaId).val()
    lat = _this.data('lat')
    lng = _this.data('lng')

    $.post '/user/areasettings/save_area', {
      id: areaId
      name: areaName
      latitude: _this.data('lat')
      longitude: _this.data('lng')
    }, (data) =>
      area = {id: data.id, name: data.name, latitude: lat, longitude: lng}
      if !data.updating
        # Creating and adding new marker to the map
        self.initMarkerAndAddToMap(area)
        leaf.map.removeLayer(markers.new_marker)

      msg = '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
      $('#area_notification_message').html msg
      _this.parent().hide()
      oldHtml = _this.parent().prev().html()
      _this.parent().prev().html(oldHtml.replace(/\_new/g, "_#{area.id}"))
      _this.parent().prev().show()
      _this.parent().prev().find('.area-name').html(data.name)


  $('#map').on 'click', '.delete-area', ->
    _this = $(this)
    areaId = _this.attr('id').replace('delete_', '')

    $.post '/user/areasettings/delete_area', { id: areaId }, (data) ->
      markerToDelete = markers.area_markers[areaId]
      leaf.map.removeLayer(markerToDelete)
      delete(markers.area_markers[areaId])

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
