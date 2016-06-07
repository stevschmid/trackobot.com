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

  $('.bulk-edit-form').submit (event) ->
    form = this
    $('.bulk-edit-picker:checked').each ->
      $('<input/>', type: 'hidden', name: 'result_ids[]', value: this.value)
        .appendTo(form)

  # timeline
  loadContentForPopover = (cls, event, options) ->
    options = $.extend {}, options

    $(cls)[event] ->
      btn = $(this)

      return unless btn.data('content-path') and !btn.hasClass('has-popover')
      $.get btn.data('content-path'), (content) ->
        options = $.extend options,
          html: true
          container: 'body'
          trigger: event
          content: content

        btn.unbind(event).addClass('has-popover')
        btn.popover(options).popover('show')

  $('.deck-edit-button').click ->
    button = $(this).addClass('hidden')
    label = $(this).siblings('.hero-label').addClass('hidden')
    form = $(this).siblings('form').removeClass('hidden')

    $('select', form).focus() # for esc
    $('select', form).on 'blur', (e) ->
      button.removeClass('hidden')
      label.removeClass('hidden')
      form.addClass('hidden')

  $("select[name='result[deck_id]'], select[name='result[opponent_deck_id]']").change (event) ->
    select = $(this)
    selected = $("option:selected", select).text()
    form = $(select).parent('form')
    $.ajax
      type: form.attr('method')
      url: form.attr('action')
      data: form.serialize(),
      success: ->
        $(form).siblings('.hero-label').text(selected)
        $(select).blur()

  loadContentForPopover '.card-history-button', 'click', placement: 'bottom'
  loadContentForPopover '.timeline-button', 'click', placement: 'bottom'
