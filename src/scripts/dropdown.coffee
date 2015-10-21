$(() ->

  closeAll = () ->
    #aria classes
    $('.dropdown').removeClass 'open'
      .children('button, a').attr('aria-expanded', false)
    $('.dropdown-dismiss').remove()
    return

  open = (dropdown) ->
    # close any other dropdowns that are open
    # we could consider scooping this to a common
    # parent but until is becomes a problem this is
    # good enough
    closeAll()

    #aria classes
    dropdown.addClass 'open'
    dropdown.children('button, a').attr('aria-expanded', true)

    # http://perfectionkills.com/detecting-event-support-without-browser-sniffing/
    # of for object properties rather than in for arrays
    if('ontouchstart' of document.documentElement)
      $('<div class=\'dropdown-dismiss\'></div>')
        .on('click', () -> close(dropdown))
        .insertAfter(dropdown)

    return

  toggle = (e) ->
    if $(this).is(':disabled')
      return
    e.preventDefault()
    e.stopPropagation()
    dropdown = $(this).parents('.dropdown')
    isOpen = dropdown.hasClass('open')

    if isOpen
      closeAll()
    else
      open(dropdown)

  closeAll()
  $('.dropdown button, .dropdown a').click toggle
  $(document).on 'click.cyclops.dropdown', (event) ->
    dropdown = $('.dropdown.open')
    closeAll()


  $.fn.dropdown = () ->
    @each ->
      $(this).click toggle

  return
)
