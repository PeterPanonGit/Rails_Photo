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
  return

$(document).on 'turbolinks:load', bindTagsFunctionality