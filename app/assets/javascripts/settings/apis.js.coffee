# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).on 'click', '#reveal_api_token', ->
  $('#api_token').val($('#api_token').data('token'))

