global = this

global.NavigationBar = ->
  @searchedAdItems = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value')
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote:
      url: '/getItems?item=QUERY&type=search_post_items'
      wildcard: 'QUERY')
  @searchedAdItems.clearPrefetchCache()
  @searchedAdItems.initialize()
  @init()

NavigationBar::init = ->
  _this = this
  # Press Enter to valid search form.
  $('#nav_search_form input').keypress (event) ->
    if event.which == 13
      event.preventDefault()
      _this.processSearch()

  # Navigation - Search form: Ajax call to get locations proposition, based on user input in this form.
  $('#btn-form-search').click ->
    _this.processSearch()



  # Popover when "Sign in / Register" link is clicked, in the navigation bar.
  $('#popover').popover
    html: true
    placement: 'bottom'
    title: ->
      $('#popover-head').html()
    content: ->
      $('#popover-content').html()

  # Type-ahead for the item text field, in the main navigation bar.
  # searched_ad_items object is initialized in home layout template.
  $('#item').typeahead null,
    name: 'item-search'
    display: 'value'
    source: _this.searchedAdItems

  # Changing the typeahead query, depending of user choice between "I'm giving away" and "I'm searching for".
  $('#q').change(->
    _this.searchedAdItems.remote.url = '/getItems?item=QUERY&type=search_post_items&q=' + $('#q').val()
    # As the type of search changes, the item name field needs to be reset.
    $('#item').val ''
  ).change()


# Checks if we need to show the arrow up, in the navigation bar, on mobile devices.
show_hide_up_arrow = ->
  scrollPos = $(window).scrollTop()
  if scrollPos <= 0
    $('#navbar-up-link').hide()
  else
    $('#navbar-up-link').show()


# Processing search (item and location search)
NavigationBar::processSearch = ->
  itemValue = $('#item').val()
  queryValue = $('#q').val()
  params = {q: queryValue, item: itemValue}

  $.ajax
    url: '/search'
    global: false
    type: 'POST'
    data:
      item: itemValue
      q: queryValue
    dataType: 'html'
    beforeSend: (xhr) ->
      xhr.setRequestHeader 'Accept', 'text/html-partial'
    success: (data) ->
      d = JSON.parse(data)

      global.navState.q = queryValue
      global.navState.item = itemValue

      global.navState.populateSearchResultsSidebar(d.results)

      global.navState.cat = []
      searchItemNavState = []
      $('.guided-nav-category').each (i, el)->
        $(el).show()
        if $(el).attr('id') in d.categories
          searchItemNavState.push $(el).attr('id')
        else
          $(el).hide()

      global.navState.updateMarkersOnMap(data)
      global.navState.applyQueryParams(params)
      markers.registerAreaMarkers(d.areas, true)
      updateCategorySidebarHeight()
      

###
# Before submitting the form with the location, we first do an Ajax call to see
# if the Nominatim webservice comes back with several addresses.
#
# if it does, we show a modal window with this list of addresses. Once one is chosen,
# the form is submitted.
###
NavigationBar::getLocationsPropositions = ->
  if $('#location').val() != ''
    # A location has been entered, let's use the Nominatim web service
    locationInput = $('#location').val()
    $.ajax
      url: '/getNominatimLocationResponses'
      global: false
      type: 'GET'
      data: location: locationInput
      cache: false
      beforeSend: (xhr) ->
        xhr.setRequestHeader 'Accept', 'application/json'
        xhr.setRequestHeader 'Content-Type', 'application/json'
        $('#btn-form-search').html 'Loading...'
        return
      success: (data) ->
        modalHtmlText = ''
        if data != null and data.length > 0
          if typeof data[0]['error_key'] != 'undefined'
            # There's been an error while retrieving info from Nominatim,
            # or there is no result found for this address.
            $('#search_error_message').html '<strong>' + data[0]['error_key'] + '</strong>'
          else
            # Address suggestions were found.
            # We need to create the HTML body of the modal window, based on the location proposition from OpenStreetMap.
            modalHtmlText = '<p>Choose one of the following available locations</p><ul></ul>'
            # We also need to consider whether an item is being searched/given at the same time.
            item = $('#item').val()
            search_action = $('#q').val()
            i = 0
            while i < data.length
              proposed_location = data[i]
              url = '/search?lat=' + proposed_location['lat'] +
                '&lon=' + proposed_location['lon'] + '&loc=' + proposed_location['display_name']
              if item != ''
                url = url + '&item=' + item
              if search_action != ''
                url = url + '&q=' + search_action
              modalHtmlText = modalHtmlText + '<li><a href=\'' + encodeURI(url) + '\'>' +
                  proposed_location['display_name'] + '</a></li>'
              
              i++
            modalHtmlText = modalHtmlText + '</ul>'
            $('#modal-body-id').html modalHtmlText
            options =
              'backdrop': 'static'
              'show': 'true'
            $('#basicModal').modal options
        # Webservice response came back - button label goes back to "Search"
        $('#btn-form-search').html 'Search'

  else if $('#item').val() != '' or $('#user_action').val() != ''
    # no location is being searched, but an item is. We need to submit the form with this information.
    $('#nav_search_form').submit()