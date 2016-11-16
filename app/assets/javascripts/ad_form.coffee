global = this

global.AdForm = ->
  @init()

AdForm::init = ->

  if $('#locations_from_list').length > 0
    $('.location-form-for-ad').hide()

  # This is a test to see if the user is using clients like AdBlock.
  # The use of AdBlock blocks a lot of markups on this website, unfortunately
  # (eg. everything that has 'ad' in the class name). When AdBlock is detected, we display a popup indicating
  # that AdBlock should be deactivated for this Madloba website.
  if $('#ad-block').length and !$('#ad-block').height()
    $('#wrap').append '<div class="blocking-notification alert alert-dismissible alert-warning" role="alert">' + \
        '<button type="button" class="close" data-dismiss="alert">×</button>' + \
        '<h5>' + gon.vars['adblock_warning'] + '</h5>' + \
        '<p>' + gon.vars['adblock_browser'] + '<br />' + gon.vars['adblock_affecting'] + '</p>' + \
        '<p>' + gon.vars['adblock_turnoff'] + '</p>' + '</div>'
  # Initially created in 'application.html.haml' layout, this div is now removed.
  $('#ad-block').remove()

  bindTypeaheadToItemSelect $('#items .selectpicker-items')
  
  # "Create/Edit ad" form: create message when image needs to be uploaded.
  $('#new_ad').submit ->
    image_path = $('#ad_image').val()
    if image_path != null and image_path != ''
      $('#upload-in-progress').html '<i>' + gon.vars['new_image_uploading'] + '</i>'

  # Events to be triggered when item field added or removed, in the ad form.
  $('#items a.add_fields').data('association-insertion-position', 'before').data 'association-insertion-node', 'this'
  $('#items').on 'cocoon:after-insert', ->
    $('.ad-item-fields a.add_fields').data('association-insertion-position', 'before').data \
      'association-insertion-node', 'this'
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
  resetLocationForm()

  # "Edit ad" form: create message when image needs to be uploaded.
  $('#ad_edit_form').submit ->
    image_path = $('#ad_image').val()
    if image_path != null and image_path != ''
      $('#upload-in-progress').html '<i>' + gon.vars['new_image_uploading'] + '</i>'

  # "New ad" form: open location form when clicking on "Enter new location" button
  $('.add-new-location').click ->
    $('.location-form-for-ad').show()
    $('.add-new-location').hide()
    $('.location-form-for-ad :input').attr("disabled", false)
    $('#locations_from_list :input').attr('disabled', true)
    $('#locations_from_list').hide()
    $(".remove-new-location").attr("tabindex",-1).focus() # Hack to center page on new location title.

  $('.remove-new-location').click ->
    $('.location-form-for-ad').hide()
    $('.add-new-location').show()
    $('.location-form-for-ad :input').attr("disabled", true)
    $('#locations_from_list :input').attr('disabled', false)
    $('#locations_from_list').show()

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


# This function initializes the location form (Location edit form, Ad forms)
# as well as all the events tied to its relevant elements.
resetLocationForm = ->
  if $('#map').length > 0
    $('.location_type_exact').click ->
      removes_location_layers()
      show_exact_address_section()

    if $('.location_type_exact').is(':checked')
      show_exact_address_section()

    $('.location_type_district').click ->
      removes_location_layers()
      show_district_section_only()

    if $('.location_type_district').is(':checked')
      show_district_section_only()

  # Help messages for fields on "Create ad" form
  $('.help-message').popover()
  # Initializing onclick event on "Locate me on the map" button, when looking for location on map, based on user input.
  find_geocodes()

# Function used in the location form - show appropriate section when choosing a district-based area
show_district_section_only = ->
  $('.exact_location_section').addClass 'hide'
  $('#map_notification_exact').addClass 'hide'
  $('.exact_location_section :input').attr('disabled', true)
  
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
  ).change()


# On the location form, removes layers representing a previously clicked exact location, postal code area,
# or selected district.
removes_location_layers = ->
  if markers.new_marker != null
    leaf.map.removeLayer markers.new_marker
  if markers.selected_area != null
    leaf.map.removeLayer markers.selected_area

# Function used in the location form - show appropriate section when entering an exact address
show_exact_address_section = ->
  $('.exact_location_section').removeClass 'hide'
  $('.exact_location_section :input').attr('disabled', false)

  markers.location_marker_type = 'exact'
  leaf.map.on 'click', onMapClickLocation
  $('#map_notification_exact').removeClass 'hide'
