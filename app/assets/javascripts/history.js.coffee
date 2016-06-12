# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->
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

  $('.result-delete-button').on 'ajax:success', (e, data, status, xhr) ->
    $(this).closest('tr').fadeOut 500, ->
      $(this).remove()

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
    full_name = $("option:selected", select).data('full-name')
    form = $(select).parent('form')
    $.ajax
      type: form.attr('method')
      url: form.attr('action')
      data: form.serialize(),
      success: ->
        $(form).siblings('.hero-label').text(full_name)
        $(select).blur()

  loadContentForPopover '.card-history-button', 'click', placement: 'bottom'
  loadContentForPopover '.timeline-button', 'click', placement: 'bottom'
