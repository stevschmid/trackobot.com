# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Show corresponding bulk-edit checkbox when hover over hero-icon
# When selecting a checkbox show all bulk-edit checkboxes (remove hover?)
# Canceling or unchecking all boxes goes back to hover behavior

jQuery ->
  $(".bulk-edit-picker").click ->
    if $(".bulk-edit-picker").is(":checked")
      $(".bulk-edit-control").addClass("bulk-edit-on")
    else
      $(".bulk-edit-control").removeClass("bulk-edit-on")
  $("#bulk_edit_cancel").click ->
    $(".bulk-edit-picker").prop("checked", false)
    $(".bulk-edit-control").removeClass("bulk-edit-on")