global = this

global.Sidebar = ->
  updateCategorySidebarHeight()
  @init()

Sidebar::init = (e) ->
  $('.sidebar-icon').click ->
    targetElement = $(this).attr('href')
    h = $(targetElement).height() + 50
    $('.sidebar-left').height(h)
