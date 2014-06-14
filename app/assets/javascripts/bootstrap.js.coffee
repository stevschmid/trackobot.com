$(document).on 'ready page:load', ->
  $("a[rel~=popover], .has-popover").popover()
  $("a[rel~=tooltip], .has-tooltip").tooltip()

  # close other popovers on click
  $('.has-popover, .timeline-button').on 'click', -> 
    $('.has-popover, .timeline-button').not(this).popover('hide').next('.popover').remove()

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
