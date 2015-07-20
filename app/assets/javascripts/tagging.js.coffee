
$(document).on 'ready page:load', ->
  $('.tagging .input').attr('size', 1)

  $.fn.isImmutableTag = (tagText) ->
    str = $(this).data('immutable-tags') || ''
    array = str.split(',')
    return tagText in array

  $.fn.addTag = (tagText) ->
    tagText = tagText
      .toLowerCase()
      .replace(',', '')
      .trim()

    return if tagText.length == 0

    # remove potential duplicated entry
    $('li', this).filter(->
      $.text([ this ]) == tagText
    ).remove() 

    # add new tag
    li = $('<li>')
      .text(tagText)
      .addClass(tagText)
      .appendTo(this)

    unless $(this).isImmutableTag(tagText)
      # delete link
      $('<i class="delete-tag fa fa-times"></i>').click(->
        $(this).parent().remove()
      ).appendTo(li)

  $.fn.removeTag = (tagText) ->
    unless $(this).isImmutableTag(tagText)
      $('li', this).filter(->
        $.text([ this ]) == tagText
      ).remove() 

  $.each $('.tagging .tags li'), (i, li) ->
    parent = $(li).parent()
    $(li).remove()
    $(parent).addTag $(li).text()

  $('.tagging').on 'click', (e) ->
    $('.input', this).focus()

  $('.tagging .tags li').on 'click', (e) ->
    console.log('click')
    return false

  $('.tagging .input').on 'blur', (e) ->
    tags = $('.tags', $(this).parent())
    $(tags).addTag $(this).val()
    $(this).val ''

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

