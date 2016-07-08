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

  $('.history-query-clear').click ->
    $('.history-query').val('').closest('form').submit()

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
    selected = $("option:selected", select).text()
    form = $(select).parent('form')
    $.ajax
      type: form.attr('method')
      url: form.attr('action')
      data: form.serialize(),
      success: ->
        $(form).siblings('.hero-label').text(selected)
        $(select).blur()

  $('.note-edit-button').click ->
    button = $(this)
    current_note = button.attr('data-original-title')
    new_note = prompt('Enter note:', current_note)

    if new_note != null && current_note != new_note
      $.ajax
        type: 'PUT'
        url: button.attr('href')
        data: 
          result: 
            note: new_note
        success: ->
          button.attr('data-original-title', new_note).tooltip('show')
          if !new_note.trim()
            button.removeClass('note-present')
          else
            button.addClass('note-present')

    false

  $('.rank-edit-button').popover
    html: true
    placement: 'right'
    content: ("<a href='#' data-rank='#{r}'><div class='ranks-rank#{r}' title='Rank #{r}'></div></a>" for r in [1..25]).join('')
    trigger: 'focus'
    template: '<div class="popover rank-edit-popover" role="tooltip"><div class="arrow"></div><div class="popover-content"></div></div>'

  # Need to stop default behaviour, but popover will still show. Don't create
  # popover here because it works not "normally" for multiple shows and unshows.
  $('.rank-edit-button').click ->
    false
  
  # When the popover is created (dynamically) is when we add callbacks to the
  # rank pins. The elements don't exist until they're shown.
  $('.rank-edit-button').on 'shown.bs.popover', ->
    button = $(this)
    $("#" + $(this).attr('aria-describedby') + " a").click ->
      new_rank = $(this).data('rank')
      $.ajax
        type: 'PUT'
        url: button.attr('href')
        data:
          result:
            rank: new_rank
        success: ->
          button.parent().html("<div class='ranks-rank#{new_rank}' title='Rank #{new_rank}'></div>")

  loadContentForPopover '.card-history-button', 'click', placement: 'bottom'
  loadContentForPopover '.timeline-button', 'click', placement: 'bottom'
