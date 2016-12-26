$(document).on 'turbolinks:load', ->
  $(".chosen-select").chosen()

  $("a[rel~=popover], .has-popover").popover()
  $("a[rel~=tooltip], .has-tooltip").tooltip()

  $("span.pie").peity "pie",
    fill: ["#3498db", "#eee"]

  $("span.bar").peity "bar",
    fill: ["#3498db"]

  $("[data-target-path]").click ->
    self.location.href = $(this).data('target-path')

  # user rename
  profile = $('.profile')
  $('.rename-button', profile).click ->
    $('.rename', profile).removeClass('hidden')
    $('.name, .rename-button', profile).addClass('hidden')
    $('form input', profile).select().focus()

  $('form', profile).on 'keyup', (e) ->
    if e.which == 27 # esc
      $('.rename', profile).addClass('hidden')
      $('.name, .rename-button', profile).removeClass('hidden')

# close popover when clicking outside of current popover
$(document).on "mousedown", (e) ->
  $(".has-popover").each ->
    #the 'is' for buttons that trigger popups
    #the 'has' for icons within a button that triggers a popup
    $(this).popover "hide"  if not $(this).is(e.target) and $(this).has(e.target).length is 0 and $(".popover").has(e.target).length is 0
