# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@assignAjaxPagination = (e) ->
  if $('.pagination').length
    $(window).scroll ->
      url = $('.pagination .next_page').attr('href')
      if url and $(window).scrollTop() > $(document).height() - $(window).height() - $(".queue-image").height()
        $('.pagination').text 'Please wait...'
        return $.getScript(url)
      return
    return $(window).scroll()
  return

$(document).on 'turbolinks:load', assignAjaxPagination