# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Show corresponding bulk-edit checkbox when hover over hero-icon
# When selecting a checkbox show all bulk-edit checkboxes (remove hover?)
# Canceling or unchecking all boxes goes back to hover behavior

$(document).on 'ready page:load', ->
  # bulk edit
  $('.bulk-edit-picker').click ->
    $('.bulk-edit-control').toggleClass('bulk-edit-on', $('.bulk-edit-picker').is(':checked'))

  $('#bulk_edit_cancel').click ->
    $('.bulk-edit-control').removeClass('bulk-edit-on')
    $('.bulk-edit-picker').prop('checked', false)

  $('.history-query-clear').click ->
    $('.history-query').val('').closest('form').submit()

  # timeline
  options =
    placement: (context, source) ->
      position = $(source).position()
      # the timeline is max ~550px in height
      if position.top - 280 < 0 
        # rearrange to bottom
        # otherwise it is cut off the top
        "bottom"
      else
        "right"

    trigger: "click"

  $(".timeline-button").popover options
