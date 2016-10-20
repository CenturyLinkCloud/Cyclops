$(() ->
  toggle = () ->
    btn = $(this)
    menu = btn.parents('.navbar').find('.navbar-collapse')
    if menu.is(':visible')
      menu.stop().slideUp 300, ->
        setAriaAndClass(menu, btn)
    else
      menu.stop().slideDown 300, ->
        setAriaAndClass(menu, btn)
    return

  setAriaAndClass = (menu, btn) ->
    isVisible = menu.is(':visible')
    menu.attr('aria-expanded', isVisible)
    btn.attr('aria-expanded', isVisible)
    if(isVisible)
      menu.removeClass('collapsed')
      btn.addClass('open')
    else
      menu.addClass('collapsed')
      btn.removeClass('open')
    return

  $.fn.navbar = () ->
    @each ->
      $nb = $(this)
      menu = $nb.find('.navbar-collapse')
      btn = $nb.find('.navbar-toggle')

      isVisible = menu.is(':visible')
      menu.attr('aria-expanded', isVisible)
      btn.attr('aria-expanded', isVisible)

      btn.click toggle
    return

  $("nav.navbar").each (idx, nb) ->
    $(nb).navbar()

)
