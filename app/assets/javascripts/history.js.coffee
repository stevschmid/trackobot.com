# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Show corresponding bulk-edit checkbox when hover over hero-icon
# When selecting a checkbox show all bulk-edit checkboxes (remove hover?)
# Canceling or unchecking all boxes goes back to hover behavior

jQuery ->
  $('html').on 'click', '.bulk-edit-picker', ->
    $('.bulk-edit-control').toggleClass('bulk-edit-on', $('.bulk-edit-picker').is(':checked'))
  $('html').on 'click', '#bulk_edit_cancel', ->
    $('.bulk-edit-control').removeClass('bulk-edit-on')