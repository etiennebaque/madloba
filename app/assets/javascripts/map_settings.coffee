$(document).ready ->
  events.init_map_settings_page()

events =
  init_map_settings_page: ->
    # Map settings admin page: refreshing map, when "Map type" field is modified.
    $('#maptype').change ->
      selected_map = ''
      $('select option:selected').each ->
        selected_map = $(this).val()
        return
      map_settings['chosen_map'] = selected_map
      map_settings['tiles_url'] = map_settings[selected_map]['tiles_url']
      map_settings['attribution'] = map_settings[selected_map]['attribution']
      initLeafletMap map_settings
      return

