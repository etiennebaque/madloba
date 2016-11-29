# Using this root context variable to define global variables later on.
global = this

###*
# Creation of the AdSocket class that holds all
# the behaviour related to websockets, client side.
# Websocket-powered communication is used
# when selecting categories on the guided navigation.
###

global.AdSocket = ->
  @socket = new WebSocket(App.websocket_url + '/websocket')
  @initBinds()
  return

messagePrefix =
  refresh_map: 'map'
  add_new_marker: 'new'

# Initialisation of the websocket.

AdSocket::initBinds = ->
  _this = this

  # Message sent to server when a new ad has just been created
  # (ie. new ad notification message has been loaded on ads#show)
  $(document).ready ->
    new_ad_id = $('#new_ad_id').val()
    if typeof new_ad_id != 'undefined'
      _this.sendNewAdNotification new_ad_id
    return

  @socket.onmessage = (e) ->
    # We will have a status message in our response:
    # error
    # new_marker
    response = JSON.parse(e.data)
    status = response['status']
    map_info = response['map_info']
    # new_nav_state = _this.nav_state
    switch status
      when 'error'
        _this.error_map map_info
      when 'new_ad'
        _this.add_marker map_info
    return

  return

# Sending the new navigation state to the server, in order to get the relevant markers and areas.
#AdSocket::sendNavState = (value) ->
#  @socket.send messagePrefix.refresh_map + value
#  return

# Sending a message to the server to notify other users that a new ad has been created, and to display on other users' home page map.

AdSocket::sendNewAdNotification = (value) ->
  @send messagePrefix.add_new_marker + value
  return


# This method allows to update the URL without redirecting, when a category is selected.
# By doing so, we give the user the possibility to reload the page on a specific category nav state.
# (Not used for now)
AdSocket::updateURL = (new_nav_state) ->
  params = location.search
  current_url = window.location.href
  new_cat_params = 'cat=' + new_nav_state.cat.join('+')
  new_url = ''
  if params != ''
    param_array = params.replace('?', '').split('&')
    cat_param = ''
    i = 0
    while i < param_array.length
      if param_array[i].indexOf('cat=') > -1
        cat_param = param_array[i]
        break
      i++
    if cat_param != ''
      if new_cat_params == 'cat='
        new_url = current_url.replace(cat_param, '')
      else
        new_url = current_url.replace(cat_param, new_cat_params)
    else
      new_url = current_url + '&' + new_cat_params
  else
    if new_cat_params == 'cat='
      new_url = current_url
    else
      new_url = current_url + '?' + new_cat_params
  if new_url.indexOf('?#') > -1
    new_url = new_url.replace('?#', '')
  history.replaceState 'data', '', new_url
  return

AdSocket::error_map = (message) ->
  # if there's been an websocket error, use the 'search_error_message' div in navbar to display an error message
  $('#search_error_message').html message
  return

# Method that place the new markers sent back from the server

AdSocket::add_marker = (new_map_info) ->
  exactLocationsAds = new_map_info['markers']
  isSeveralItems = exactLocationsAds[0]['markers'].length > 1
  if isSeveralItems
    # There are several markers to add on the map. Let's not bounce them, as animation conflicts with MarkerClusterGroup.
    markers.place_exact_locations_markers exactLocationsAds, false
  else
    # 1 marker to add, let's make it bounce.
    markers.place_exact_locations_markers exactLocationsAds, true
  return

# Custom 'send' function, making sure that the websocket connection is available.

AdSocket::send = (message) ->
  socket = @socket
  @waitForConnection (->
    socket.send message
    return
  ), 1000
  return

AdSocket::waitForConnection = (callback, interval) ->
  if @socket.readyState == 1
    callback()
  else
    that = this
    # optional: implement backoff for interval here
    setTimeout (->
      that.waitForConnection callback, interval
      return
    ), interval
  return
