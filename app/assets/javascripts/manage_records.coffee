global = this

global.ManageRecords = ->
  @init()

ManageRecords::init = ->
  # Manage record page: go to the right tab, if page loads with an anchor in url (like 'http://...#categories')
  if window.location.href.indexOf('managerecords') > -1 and window.location.hash
    $('#records-tabs a[href=' + window.location.hash + ']').tab 'show'