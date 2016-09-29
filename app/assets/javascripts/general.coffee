# Using this root context variable to define global variables later on.
global = this

# Object used for autocompletion when user searches for an item, in navigation bar

###*
# Function that binds events to the item drop down list (in ads#new and ads#edit pages)
# These events consists of making ajax call to check what items exists, in order to
# create a type-ahead for the search bar of that drop drown box.
# @param object
###

bindTypeaheadToItemSelect = (object) ->
  object.selectpicker(liveSearch: true).ajaxSelectPicker
    ajax:
      url: '/getItems'
      type: 'GET'
      dataType: 'json'
      data: ->
        params =
          item: '{{{q}}}'
          type: 'search_items'
        params
    locale:
      emptyTitle: gon.vars['search_for_items']
      statusInitialized: gon.vars['start_typing_item']
      statusNoResults: gon.vars['no_result_create_item']
    preprocessData: (data) ->
      items = []
      len = data.length
      # Populating the item drop-down box
      i = 0
      while i < len
        item = data[i]
        items.push
          'value': item.id
          'text': item.value
          'disable': false
        i++
      items
    preserveSelected: false
  return

###*
# This critical function initializes the location form (Location edit form, Ad forms)
# as well as all the events tied to its relevant elements.
###

resetLocationForm = (districts_bounds, map) ->
  if $('#map').length > 0
    $('.location_type_exact').click ->
      removes_location_layers()
      show_exact_address_section()

    if $('.location_type_exact').is(':checked')
      show_exact_address_section()
    $('.location_type_postal_code').click ->
      removes_location_layers()
      show_postal_code_section()

    if $('.location_type_postal_code').is(':checked')
      show_postal_code_section()
    $('.location_type_district').click ->
      removes_location_layers()
      show_district_section()

    if $('.location_type_district').is(':checked')
      show_district_section()

  # "Postal code" functionality: display a help message to inform about what the area will be named,
  # after the postal code is entered.
  $('.location_postal_code').focusout ->
    if $('.location_type_postal_code').is(':checked')
      area_code_length = undefined
      postal_code_length = undefined
      postal_code = $('.location_type_postal_code').val()
      postal_code_value = $('.location_postal_code').val()
      if typeof area_code_length == 'undefined' and typeof postal_code_length == 'undefined'
        $.get '/user/getAreaSettings', {}, (data) ->
          if data['code'] != null and data['area'] != null
            # Based on the retrieved settings, we display which area code will be used for this ad.
            area_code_length = data['area']
            if postal_code.length >= area_code_length
              $('#postal_code_notification').html '<i>' + gon.vars['area_show_up'] + '\'' + postal_code_value.substring(0, area_code_length) + '\'</i>'
          return
    return
  # Help messages for fields on "Create ad" form
  $('.help-message').popover()
  # Initializing onclick event on "Locate me on the map" button, when looking for location on map, based on user input.
  find_geocodes()


###*
# Event triggered when click on "Locate me on the map" button,
# on the "Create ad" form, and on the Ad edit form.
###
global.find_geocodes = ->
  $('#findGeocodeAddressMapBtnId').button().click ->
    location_type = 'exact'
    if $('.location_type_postal_code').is(':checked')
      # We're on the location edit page, and 'Postal code' or 'District' location type is checked.
      location_type = 'area'
    # Ajax call to get geocodes (latitude, longitude) of an exact location defined by address, postal code, city...
    # This call is triggered by "Find this city", "Find this general location" buttons,
    # on Map settings page, location edit page, map setup page...
    $.ajax
      url: '/getCityGeocodes'
      global: false
      type: 'GET'
      data:
        street_number: $('.location_streetnumber').val()
        address: $('.location_streetname').val()
        city: $('.location_city').val()
        postal_code: $('.location_postal_code').val()
        state: $('.location_state').val()
        country: $('.location_country').val()
        type: location_type
      cache: false
      beforeSend: (xhr) ->
        xhr.setRequestHeader 'Accept', 'application/json'
        xhr.setRequestHeader 'Content-Type', 'application/json'
        $('#findGeocodeLoaderId').html gon.vars['searching_location']
        return
      success: (data) ->
        if data != null and data.status == 'ok'
          # Geocodes were found: the location is shown on the map.
          myNewLat = Math.round(data.lat * 100000) / 100000
          myNewLng = Math.round(data.lon * 100000) / 100000
          $('.latitude_hidden').val myNewLat
          $('.longitude_hidden').val myNewLng
          # Update the center of map, to show the general area
          leaf.map.setView new (L.LatLng)(myNewLat, myNewLng), data.zoom_level
        else
          # The address' geocodes were not found - the user has to pinpoint the location manually on the map.
          $('#myErrorModal').modal 'show'
        # Displaying notification about location found.
        $('#findGeocodeLoaderId').html '<i>' + data.address_found + '</i>'


###*
# On the location form, removes layers representing a previously clicked exact location, postal code area,
# or selected district.
###
removes_location_layers = ->
  if markers.new_marker != null
    leaf.map.removeLayer markers.new_marker
  if markers.selected_area != null
    leaf.map.removeLayer markers.selected_area
  if markers.postal_code_circle != null
    leaf.map.removeLayer markers.postal_code_circle

###*
# Function used in the location form - show appropriate section when entering an exact address
###

show_exact_address_section = ->
  $('#postal_code_section').removeClass 'hide'
  $('#district_section').addClass 'hide'
  $('.exact_location_section').removeClass 'hide'
  markers.location_marker_type = 'exact'
  leaf.map.on 'click', onMapClickLocation
  $('#map_notification_postal_code_only').addClass 'hide'
  $('#map_notification_exact').removeClass 'hide'
  return

###*
# Function used in the location form - show appropriate section when choosing a postal code-based area
###

show_postal_code_section = ->
  $('.exact_location_section').addClass 'hide'
  $('#district_section').addClass 'hide'
  $('#postal_code_section').removeClass 'hide'
  markers.location_marker_type = 'area'
  leaf.map.on 'click', onMapClickLocation
  $('#map_notification_postal_code_only').removeClass 'hide'
  $('#map_notification_exact').addClass 'hide'
  return

###*
# Function used in the location form - show appropriate section when choosing a district-based area
###

show_district_section = ->
  $('.exact_location_section').addClass 'hide'
  $('#postal_code_section').addClass 'hide'
  $('#district_section').removeClass 'hide'
  $('#map_notification_postal_code_only').addClass 'hide'
  $('#map_notification_exact').addClass 'hide'
  markers.location_marker_type = 'area'
  leaf.map.off 'click', onMapClickLocation
  $('#map_notification').addClass 'hide'
  # Loading the district matching the default option in the district drop-down box.
  id = $('.district_dropdown option:selected').val()
  name = $('.district_dropdown option:selected').text()
  bounds = districts_bounds[id]
  leaf.show_single_district name, bounds
  # Location form: when choosing a district from the drop-down box, we need to display the area on the map underneath.
  $('#district_section').on('change', '.district_dropdown', ->
    id = $('.district_dropdown option:selected').val()
    name = $('.district_dropdown option:selected').text()
    bounds = districts_bounds[id]
    leaf.show_single_district name, bounds
    return
  ).change()



###*
# Checks whether the user is in the admin panel (has '/user/' in the url)
###

is_in_admin_panel = ->
  window.location.href.indexOf('/user/') > -1

# Object containing the scripts to load on different pages of the application.
# See 'custom-leaflet.coffee' file for map-related scripts.
events =
  init_new_ad_page: ->
    # This is a test to see if the user is using clients like AdBlock.
    # The use of AdBlock blocks a lot of markups on this website, unfortunately (eg. everything that has 'ad' in the class name)
    # When AdBlock is detected, we display a popup indicating that AdBlock should be deactivated for this Madloba website.
    if $('#ad-block').length and !$('#ad-block').height()
      $('#wrap').append '<div class="blocking-notification alert alert-dismissible alert-warning" role="alert">' + '<button type="button" class="close" data-dismiss="alert">×</button>' + '<h5>' + gon.vars['adblock_warning'] + '</h5>' + '<p>' + gon.vars['adblock_browser'] + '<br />' + gon.vars['adblock_affecting'] + '</p>' + '<p>' + gon.vars['adblock_turnoff'] + '</p>' + '</div>'
    # Initially created in 'application.html.erb' layout, this div is now removed.
    $('#ad-block').remove()
    # On the "New ad" form, open automatically the new location form, if the user is anonymous,
    # or never created any location as a signed in user.
    if typeof current_page != 'undefined' and current_page == 'new_ad' and typeof can_choose_existing_locations != 'undefined' and can_choose_existing_locations == false
      setTimeout (->
        $('#new_location_form a.add_fields').trigger 'click'
        $('#locations_from_list').hide()
        $('#location a.add_fields').hide()
        initLeafletMap map_settings
        resetLocationForm districts_bounds, leaf.map
        return
      ), 20
    # Create an ad: adding the location form dynamically, via Cocoon
    $('#new_location_form a.add_fields').data('association-insertion-position', 'before').data 'association-insertion-node', 'this'
    $('#new_location_form').bind 'cocoon:after-insert', ->
      $('#locations_from_list').hide()
      $('#new_location_form a.add_fields').hide()
      # Call to the JS functions that will initialize the new location form and the map.
      initLeafletMap map_settings
      resetLocationForm districts_bounds, leaf.map
      return
    $('#new_location_form').bind 'cocoon:after-remove', ->
      $('#locations_from_list').show()
      $('#new_location_form a.add_fields').show()
      return
    return

  init_new_and_edit_pages: ->
    bindTypeaheadToItemSelect $('#items .selectpicker-items')
    # "Create/Edit ad" form: create message when image needs to be uploaded.
    $('#new_ad').submit ->
      image_path = $('#ad_image').val()
      if image_path != null and image_path != ''
        $('#upload-in-progress').html '<i>' + gon.vars['new_image_uploading'] + '</i>'

    # Events to be triggered when item field added or removed, in the ad form.
    $('#items a.add_fields').data('association-insertion-position', 'before').data 'association-insertion-node', 'this'
    $('#items').on 'cocoon:after-insert', ->
      $('.ad-item-fields a.add_fields').data('association-insertion-position', 'before').data 'association-insertion-node', 'this'
      $('.selectpicker').selectpicker 'refresh'
      bindTypeaheadToItemSelect $('#items .selectpicker-items')
      $('.ad-item-fields').on 'cocoon:after-insert', ->
        $(this).children('.item_from_list').remove()
        $(this).children('a.add_fields').hide()

    $('.ad-item-fields').bind 'cocoon:after-insert', (e) ->
      e.stopPropagation()
      $(this).find('.item_from_list').remove()
      $(this).find('a.add_fields').hide()
      $('.selectpicker').selectpicker 'refresh'

    # Function call to initialize the location form (Location edit form, all Ad forms).
    if typeof districts_bounds != 'undefined'
      resetLocationForm districts_bounds, leaf.map
    return

  init_admin_pages: ->
    # "Edit ad" form: create message when image needs to be uploaded.
    $('#ad-edit-form').submit ->
      image_path = $('#ad_image').val()
      if image_path != null and image_path != ''
        $('#upload-in-progress').html '<i>' + gon.vars['new_image_uploading'] + '</i>'

    # Character counter (class 'textarea_count'), for text area, in 'General settings'.
    $('.textarea_count').keyup ->
      maxlength = $(this).attr('maxlength')
      textlength = $(this).val().length
      $('.remaining_characters').html maxlength - textlength

    $('.textarea_count').keydown ->
      maxlength = $(this).attr('maxlength')
      textlength = $(this).val().length
      $('.remaining_characters').html maxlength - textlength

    # Category edit page: opening up the icon modal window.
    $('.btn-icon-modal').click ->
      $('#myModalIcon').modal 'show'

    # Onclick event triggered when Icon clicked in modal window, in Category edit page.
    $('.icon-for-category').click ->
      icon_key = $(this).attr('id')
      $('#myModalIcon').modal 'toggle'
      $('#category_icon').val icon_key

    # Manage record page: go to the right tab, if page loads with an anchor in url (like 'http://...#categories')
    if window.location.href.indexOf('managerecords') > -1 and window.location.hash
      $('#records-tabs a[href=' + window.location.hash + ']').tab 'show'


###*
# Loading scripts here.
###

$(document).ready ->
  events.init_new_ad_page()
  events.init_new_and_edit_pages()
  # load additional scripts when user is in the admin panel.
  if is_in_admin_panel()
    events.init_admin_pages()
  return
