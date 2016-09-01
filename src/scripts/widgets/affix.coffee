calculateAndSetNewPosition = (start, element) ->
  newTopPosition = start - $(window).scrollTop()
  if newTopPosition < 0
    newTopPosition = 0
  $(element).css('top', newTopPosition)

$.fn.affix = () ->
  console.warn('Affix is deprecated. You should use sticky positioning (i.e. "position: sticky") in your CSS instead.')
  $(this).each (idx, ele) ->
    startingTopPosition = $(ele).position().top
    calculateAndSetNewPosition(startingTopPosition, ele)
    $(window).on 'scroll', () ->
      calculateAndSetNewPosition(startingTopPosition, ele)
