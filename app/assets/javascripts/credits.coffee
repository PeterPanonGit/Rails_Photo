# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@bindAdsTracking = (e) ->
  isOverGoogleAd = false

  $('[data-ad="true"]').mouseover(->
    isOverGoogleAd = true
    return
  ).mouseout ->
    isOverGoogleAd = false
    return

  $(window).blur(->
    if isOverGoogleAd
      $("#add-credits").click()
    return
  ).focus()

  return

$(document).on 'turbolinks:load', bindAdsTracking