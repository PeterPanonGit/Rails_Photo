# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@showTip = ->
  $(".tip[data-tip=1]").slideDown()
  return

@toggleTip = (e) ->
  num = parseInt($(@).parent().data('tip')) + 1
  $(@).parent().slideUp()
  $(".tip[data-tip=" + num + "]").slideDown()
  return

@bindTagsFunctionality = ->
  $('[class^="tag"]').click (e) ->
    e.preventDefault()
    $(this).toggleClass 'active'
    applyTags()
  $('#unselect-all').click ->
    $('.wrapper-tags .active').toggleClass('active')
    $("#all-styles .styles").children().show()
  applyTags()
  return

@applyTags = ->
  $("#all-styles .styles").children().hide()
  tags = new Array()
  $('.wrapper-tags .active').each (i) ->
    tags.push $(@).data('tag').split(' ').join('-')
    return
  tags = tags.join(".")
  if tags.length > 0
    $("#all-styles .styles").find("." + tags).show()
  else
    $("#all-styles .styles").children().show()
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
      ), 25000)
      intervals.push(interval)
      return
    $(document).on 'turbolinks:click', ->
      intervals.forEach (elem) ->
        clearInterval elem
        return
      return
  return

@markStyle = (e) ->
  id = $(@).data 'style-id'
  $('[class^="mark_style_"]').html ''
  $('.mark_style_' + id).html '<div class="marked"><img src="/check.png" class="imagesStyle"</div>'
  $('#queue_image_style_id').val id
  return

@markQueueImage = (e) ->
  id = $(@).data 'my-image-id'
  $('.my-image-block').removeClass 'active'
  $(@).addClass 'active'
  $('#queue_image_content_id').val id
  return

@bindMarkFunctionality = (e) ->
  $(document).on 'click', '.style-block', markStyle
  $(document).on 'click', '.my-image-block', markQueueImage
  return

$(document).on 'turbolinks:load', bindTagsFunctionality
$(document).on 'turbolinks:load', loadProcessedImage
$(document).on 'turbolinks:load', bindMarkFunctionality

$(document).on 'click', '#credits-tip', showTip
$(document).on 'click', '.tip .btn', toggleTip