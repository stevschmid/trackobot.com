# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $("#edit_history").click ->
    $(".choose").toggle()
    $("input[type=submit]").toggle()