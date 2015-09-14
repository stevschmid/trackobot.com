# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('ul.gallery a').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    shade = $('<div>').css position: 'fixed', top: 0, bottom: 0, left: 0, right: 0, backgroundColor: 'rgba(0,0,0,0.5)'
    img = $('<img>').attr('src', $(this).attr('href')).css position: 'fixed', top: '50%', maxHeight: '100%', transform: 'translateY(-50%)', right: 0, left: 0, margin: '0 auto'
    $(document.body).append(shade, img).click -> shade.remove() && img.remove()
