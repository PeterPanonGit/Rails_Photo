# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@bindTagsFunctionality = ->
  $('[class^=\'tag\'').click (e) ->
    e.preventDefault()
    $("#styles").children().hide()
    $(this).toggleClass 'active'
    tags = new Array()
    $('.wrapper-tags a.active').each (i) ->
      tags.push $(@).data('tag').split(' ').join('-')
      return
    tags = tags.join(".")
    if tags.length > 0
      $("#styles").find("." + tags).show()
    else
      $("#styles").children().show()
    return
  $('#unselect-all').click ->
    $('.wrapper-tags a.active').toggleClass('active')
    $("#styles").children().show()
  return

$(document).on 'turbolinks:load', bindTagsFunctionality
$(document).on 'turbolinks:load', ->
  screen = $(window).height()
  header = $(".navbar").outerHeight(true)
  footer = $("footer").outerHeight(true)
  form = $("#new_queue_image").outerHeight(true)
  pics = $(".overflow-y-scroll").outerHeight(true)
  $(".overflow-y-scroll").css("max-height", screen - header - footer - (form - pics) + "px")
  return