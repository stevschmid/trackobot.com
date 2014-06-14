$(document).on 'ready page:load', ->
  $("a[rel~=popover], .has-popover").popover()
  $("a[rel~=tooltip], .has-tooltip").tooltip()

  # close other popovers on click
  $('.has-popover').on 'click', -> 
    $('.has-popover').not(this).popover('hide').next('.popover').remove()
