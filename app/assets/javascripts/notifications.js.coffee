# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# close notification
$(document).on 'click', '.mark-as-read', ->
  $(this).siblings('button.close').click()
