
$(document).on 'ready page:load', ->
  $('.tagging .input').attr('size', 1)

  $.fn.triggerUpdate = ->
    tags = this
    url = $(tags).data('update-url')
    return unless url?

    method = $(tags).data('update-method') || 'POST'
    timer = $(tags).data('timer')

    clearTimeout(timer) if timer

    tagTexts = ($(li).text() for li in $('li', tags))
      .filter (tagText) ->
        !$(tags).isImmutableTag(tagText)
      .join ','
       
    sendTags = ->
      $.ajax
        url: url
        type: method
        data: 
          tags: tagTexts

    $(this).data('timer', setTimeout(sendTags, 1000))

  $.fn.isImmutableTag = (tagText) ->
    str = $(this).data('immutable-tags') || ''
    array = str.split(',')
    return tagText in array

  $.fn.addTag = (tagText, opts = {update: true}) ->
    tagText = tagText
      .toLowerCase()
      .replace(',', '')
      .trim()

    return if tagText.length == 0

    # remove potential duplicated entry
    $('li', this)
      .filter (index, li) ->
        $(li).text() == tagText
      .remove()

    # add new tag
    li = $('<li>')
      .text(tagText)
      .addClass(tagText)
      .appendTo(this)

    unless $(this).isImmutableTag(tagText)
      li.addClass('mutable')
      # delete link
      $('<i class="delete-tag fa fa-times"></i>').click(->
        $(this).closest('.tags').removeTag $(this).closest('li').text()
      ).appendTo(li)

      $(this).triggerUpdate() if opts.update

  $.fn.removeTag = (tagText) ->
    unless $(this).isImmutableTag(tagText)
      $('li', this)
        .filter (index, li) ->
          $(li).text() == tagText
        .remove()

      $(this).triggerUpdate()

  $.each $('.tagging .tags li'), (i, li) ->
    tags = $(li).closest('.tags')
    $(li).remove()
    $(tags).addTag $(li).text(), update: false

  $('.tagging').on 'click', (e) ->
    $('.input', this).focus()

  $('.tagging .tags li').on 'click', (e) ->
    tags = $(this).closest('.tags')
    url = $(tags).data('tag-url')
    if url
      self.location.href = url.replace(escape(':tag:'), $(this).text())
    return false

  $('.tagging .input').on 'blur', (e) ->
    tags = $('.tags', $(this).parent())
    $(tags).addTag $(this).val()
    $(this).val('').attr('size', 1)
    $(this).attr('size', $(this).val().length + 1)

  $('.tagging .input').on 'keydown', (e) ->
    ignore = false

    currentText = $(this).val()
    tags = $('.tags', $(this).parent())

    if e.keyCode == 13 # enter
      ignore = true

      $(tags).addTag currentText
      $(this).val ''

    else if e.keyCode == 8 # backspace
      if currentText.length <= 0
        $(tags).removeTag $('li:last-child', tags).text()

    # auto resize input
    $(this).attr('size', $(this).val().length + 1)
    return !ignore

