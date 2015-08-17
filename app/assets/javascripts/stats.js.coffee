# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->
  $('.toolbar .custom').daterangepicker
    locale: 
      format: 'YYYY-MM-DD'
    opens: 'left'
    autoApply: true
    maxDate: new Date()
    startDate: $('.toolbar .custom').data('start')
    endDate: $('.toolbar .custom').data('end')

  $('.toolbar .custom').on 'apply.daterangepicker', (ev, picker) ->
    start = picker.startDate.format('YYYY-MM-DD')
    end = picker.endDate.format('YYYY-MM-DD')
    window.location.href = $(this).attr('href') + '&start=' + start + '&end=' + end
