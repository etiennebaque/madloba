global = this

global.GeneralSettings = ->
  @init()

GeneralSettings::init = ->
  # Character counter (class 'textarea_count'), for text area, in 'General settings'.
  $('.textarea_count').keyup ->
    maxlength = $(this).attr('maxlength')
    textlength = $(this).val().length
    $('.remaining_characters').html maxlength - textlength

  $('.textarea_count').keydown ->
    maxlength = $(this).attr('maxlength')
    textlength = $(this).val().length
    $('.remaining_characters').html maxlength - textlength
