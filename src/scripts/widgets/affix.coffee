calculateAndSetNewPosition = (start, element) ->
  newTopPosition = start - $(window).scrollTop()
  if newTopPosition < 0
    newTopPosition = 0
  $(element).css('top', newTopPosition)

$.fn.affix = () ->
  $(this).each (idx, ele) ->
    startingTopPosition = $(ele).position().top
    calculateAndSetNewPosition(startingTopPosition, ele)
    $(window).on 'scroll', () ->
      calculateAndSetNewPosition(startingTopPosition, ele)
