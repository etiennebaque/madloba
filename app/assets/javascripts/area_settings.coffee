global = this

global.AreaSettings = ->

  # Adding specific events on the 'Area settings' page, needed when drawing and saving districts.
  init: (districts) ->
    leaf.districts = districts
    leaf.drawn_items = L.featureGroup()
    leaf.map.addLayer(leaf.drawn_items)

    district_bounds = undefined
    layer = undefined
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

    # Event to activate 'Save district' button when district name not empty.
    $('#map').on 'keyup', '.save_district_text', ->
      if $('.save_district_text').val().length > 0
        $('.save_district').removeClass 'disabled'
      else
        $('.save_district').addClass 'disabled'

    # Events triggered once the polygon (district) has been drawn.
    leaf.map.on 'draw:created', (e) ->
      layer = e.layer
      leaf.drawn_items.addLayer layer
      # Text field and "Save district" button to show up in the popup.
      popup = L.popup(closeButton: false).setContent('<input type=\'text\' class=\'save_district_text\' style=\'margin-right:5px;\' placeholder=\'District name\'><button type=\'button\' class=\'btn btn-xs btn-success save_district disabled\'>Save district</button>')
      layer.bindPopup popup
      district_bounds = layer.toGeoJSON()
      layer.openPopup layer.getBounds().getCenter()

    # Necessity to unbind click on map, to make the "on click" event right below work.
    $('#map').unbind 'click'
    # Saving district drawing (bounds) and name.
    $('#map').on 'click', '.save_district', ->
      district_name = $('.save_district_text').val()
      $.post '/user/areasettings/save_district', {
        bounds: JSON.stringify(district_bounds)
        name: district_name
      }, (data) ->
        $('#district_notification_message').html '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
        if data.status == 'ok'
          leaf.drawn_items.removeLayer layer
          district_bounds['properties']['id'] = data.id
          district_bounds['properties']['name'] = district_name
          L.geoJson district_bounds, onEachFeature: (feature, layer) ->
            layer.bindPopup district_name
            layer.setStyle color: data.district_color
            leaf.drawn_items.addLayer layer


    # Update district name into the GeoJSON properties hash.
    $('#map').on 'click', '.update_district', ->
      new_district_name = $('.update_district_text').val()
      district_id = $('.update_district_text').attr('id')
      $.post '/user/areasettings/update_district_name', {
        id: district_id
        name: new_district_name
      }, (data) ->
        $('#district_notification_message').html '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'

      # Going through the districts and checking which one to update.
      leaf.drawn_items.eachLayer (layer) ->
        district_bounds = layer.toGeoJSON()
        if district_id == district_bounds['properties']['id']
          layer.bindPopup '<input type=\'text\' id=\'' + district_bounds['properties']['id'] + '\' class=\'update_district_text\' style=\'margin-right:5px;\' placeholder=\'District name\' value=\'' + new_district_name + '\'><button type=\'button\' id=\'save_' + district_bounds['properties']['id'] + '\' class=\'btn btn-xs btn-success update_district\'>OK</button><br /><div class=\'district_notif\'></div>'
          layer.closePopup()

    # When starting to edit a district, create new popup for each district with current name in text field.
    leaf.map.on 'draw:editstart', (e) ->
      leaf.drawn_items.eachLayer (layer) ->
        district_bounds = layer.toGeoJSON()
        layer.bindPopup '<input type=\'text\' id=\'' + district_bounds['properties']['id'] + '\' class=\'update_district_text\' style=\'margin-right:5px;\' placeholder=\'District name\' value=\'' + district_bounds['properties']['name'] + '\'><button type=\'button\' id=\'save_' + district_bounds['properties']['id'] + '\' class=\'btn btn-xs btn-success update_district\'>OK</button><br /><div class=\'district_notif\'></div>'

    # After saving new name of district, remove the text input and display new name as text only.
    leaf.map.on 'draw:editstop', (e) ->
      leaf.drawn_items.eachLayer (layer) ->
        district_bounds = layer.toGeoJSON()
        layer.bindPopup district_bounds['properties']['name']

    # Event triggered when polygon (district) has been edited, and "Save" has been clicked.
    leaf.map.on 'draw:edited', (e) ->
      layers = e.layers
      updated_districts = []
      layers.eachLayer (layer) ->
        district_bounds = layer.toGeoJSON()
        updated_districts.push district_bounds

      $.post '/user/areasettings/update_districts', { districts: JSON.stringify(updated_districts) }, (data) ->
        $('#district_notification_message').html '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'

    # Event triggered after deleting districts and clicking on 'Save'.
    leaf.map.on 'draw:deleted', (e) ->
      layers = e.layers
      district_ids = []
      layers.eachLayer (layer) ->
        district = layer.toGeoJSON()
        district_ids.push district['properties']['id']

      $.post '/user/areasettings/delete_districts', { ids: district_ids }, (data) ->
        $('#district_notification_message').html '<span class=\'' + data.style + '\'><strong>' + data.message + '</strong></span>'
