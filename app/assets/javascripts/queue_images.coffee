# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@bindTagsFunctionality = ->
  $('[class^=\'tag\'').click ->
    $(this).toggleClass 'active'
    return
  $('#tags_form input').change ->
    $('#tags_form').submit()
    return
  $('#unselect-all').click ->
    if $('#tags_form input:checked').length > 0
      $('[class^=\'tag\'').removeClass('active')
      if $('#tags_form input:checked').length < $('#tags_form input').length - 1
        $('#tags_form input').prop('checked', false)
        $('#tags_form').submit()
      else
        $('#tags_form input').prop('checked', false)
    return
  return

$(document).on 'turbolinks:load', bindTagsFunctionality