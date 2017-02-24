# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@bindTagsFunctionality = ->
  $('[class^=\'tag\'').click (e) ->
    e.preventDefault()
    $(this).toggleClass 'active'
    applyTags()
  $('#unselect-all').click ->
    $('.wrapper-tags a.active').toggleClass('active')
    $("#styles").children().show()
  applyTags()
  return

@applyTags = ->
  $("#styles").children().hide()
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

@loadProcessedImage = ->
  loadingElements = $(".queue-image-item[data-loading]")
  if loadingElements.length > 0
    intervals = new Array()
    loadingElements.each (i) ->
      elem = @
      interval = setInterval((->
        $.get('/queue_images/' + $(elem).data('item-id') + '/loaded').success((data) ->
          clearInterval interval
          return
        )
        return
      ), 15000)
      intervals.push(interval)
      return
    $(document).on 'turbolinks:click', ->
      intervals.forEach (elem) ->
        clearInterval elem
        return
      return
  return

$(document).on 'turbolinks:load', bindTagsFunctionality
$(document).on 'turbolinks:load', loadProcessedImage
###
$(document).on 'turbolinks:load', ->
  screen = $(window).height()
  header = $(".navbar").outerHeight(true)
  footer = $("footer").outerHeight(true)
  form = $("#new_queue_image").outerHeight(true)
  pics = $(".overflow-y-scroll").outerHeight(true)
  $(".overflow-y-scroll").css("max-height", screen - header - footer - (form - pics) + "px")
  return
###