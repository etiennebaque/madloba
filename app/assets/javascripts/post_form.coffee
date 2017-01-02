global = this

global.PostForm = ->
  @init()

PostForm::init = ->

  if $('#locations_from_list').length > 0
    $('.location-form-for-post').hide()
  
  # "Create/Edit post" form: create message when image needs to be uploaded.
  $('#post_form').submit ->
    image_path = $('#post_image').val()
    if image_path != null and image_path != ''
      $('#upload-in-progress').html '<i>' + gon.vars['new_image_uploading'] + '</i>'

  resetLocationForm()
  hidingShowingLocationForm()
  initItemDynamicField()


# This function initializes the location form (Location edit form, Ad forms)
# as well as all the events tied to its relevant elements.
resetLocationForm = ->
  if $('#map').length > 0

    if $('.location_type_exact').length == 0
      # No area exists yet. We initialize for exact location.
      show_exact_address_section()

    $('.location_type_exact').click ->
      removes_location_layers()
      show_exact_address_section()

    if $('.location_type_exact').is(':checked')
      show_exact_address_section()

    $('.location_type_area').click ->
      removes_location_layers()
      show_area_section_only()

    if $('.location_type_area').is(':checked')
      show_area_section_only()

  # Open modal with explanation, when clicking on "Why do I need to choose an option?"
  $('#why_choose_link').click ->
    $('#why_choose_modal').modal('show')

  # Help messages for fields on "Create post" form
  $('.help-message').popover()

  # Initializing onclick event on "Locate me on the map" button,
  # when looking for location on map, based on user input.
  find_geocodes()

hidingShowingLocationForm = ->
  # "New post" form: open location form when clicking on "Enter new location" button
  $('.add-new-location').click ->
    $('.location-form-for-post').show()
    $('.add-new-location').hide()
    $('.location-form-for-post :input').attr("disabled", false)
    $('#locations_from_list :input').attr('disabled', true)
    $(".remove-new-location").attr("tabindex",-1).focus() # Hack to center page on new location title.

  $('.remove-new-location').click ->
    $('.location-form-for-post').hide()
    $('.add-new-location').show()
    $('.location-form-for-post :input').attr("disabled", true)
    $('#locations_from_list :input').attr('disabled', false)

# This makes all the necessary inits in order for the items field to work with typeahead
# and bootstrap tagsinput plug-in.
initItemDynamicField = ->
  allItems = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value')
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/getItems?item=QUERY&type=search_items'
      wildcard: 'QUERY')
  allItems.clearPrefetchCache()
  allItems.initialize()
  
  itemField = $('.field-for-items input')
  itemField.tagsinput
    itemText: 'value'
    itemValue: 'id'
    typeaheadjs:
      name: 'allItems'
      displayKey: 'value'
      source: allItems.ttAdapter()


# Function used in the location form - show appropriate section when choosing an area-based area
show_area_section_only = ->
  $('.exact_location_section').addClass 'hide'
  $('#map_notification_exact').addClass 'hide'
  $('.exact_location_section :input').attr('disabled', true)

  # After choosing an area, moves the map to where it is.
  leaf.moveMapBasedOnArea({showAreaIcon: false, zoom: 16})
  
  leaf.map.off 'click', onMapClickLocation
  $('#map_notification').addClass 'hide'


# On the location form, removes layers representing a previously clicked exact location, postal code area,
# or selected area.
removes_location_layers = ->
  if markers.new_marker != null
    leaf.map.removeLayer markers.new_marker


# Function used in the location form - show appropriate section when entering an exact address
show_exact_address_section = ->
  $('.exact_location_section').removeClass 'hide'
  $('.exact_location_section :input').attr('disabled', false)

  # After choosing an area, do not move the map.
  # "Locate me on the map" button will be in charge of this.
  $('.area-select').off 'change'

  leaf.map.on 'click', onMapClickLocation
  $('#map_notification_exact').removeClass 'hide'
