global = this

global.MapSettings = ->

  init: ->
    # Map settings admin page: refreshing map, when "Map type" field is modified.
    $('#map_settings_form_chosen_map').change ->
      selected_map = ''
      $('select option:selected').each ->
        selected_map = $(this).val()
        return

      map_settings['chosen_map'] = selected_map
      map_settings['tiles_url'] = map_settings[selected_map]['tiles_url']
      map_settings['attribution'] = map_settings[selected_map]['attribution']
      initLeafletMap map_settings

    leaf.map.on 'zoomend', ->
      $('#zoom_level').val leaf.map.getZoom()

