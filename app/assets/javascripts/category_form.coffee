global = this

global.CategoryForm = ->
  @init()

CategoryForm::init = ->
  # Category edit page: opening up the icon modal window.
  $('.btn-icon-modal').click ->
    $('#myModalIcon').modal 'show'

  # Onclick event triggered when Icon clicked in modal window, in Category edit page.
  $('.icon-for-category').click ->
    icon_key = $(this).attr('id')
    $('#myModalIcon').modal 'toggle'
    $('#category_icon').val icon_key