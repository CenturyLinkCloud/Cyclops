(($, window) ->

  $.offScreen = (element) ->
    # Note: this compares with window, which might not be an appropriate check based on whether
    # you have absolutely positioned elements.
    docViewTop = $(window).scrollTop()
    docViewBottom = docViewTop + $(window).height()
    elemTop = $(element).offset().top
    elemBottom = elemTop + $(element).height()
    elemBottom > docViewBottom or elemTop < docViewTop

  $.scrollIntoView = (element) ->
    $element = $(element)
    if $element.length > 0 and $.offScreen(element)
      $element[0].scrollIntoView(false)
    return

  $.offScreenWithParent = (element) ->
    $element = $(element)
    parentViewTop = $element.parent().scrollTop()
    parentViewBottom = parentViewTop + $element.parent().height()
    elemTop = $element.offset().top
    elemBottom = elemTop + $element.height()
    elemBottom > parentViewBottom or elemTop < parentViewTop

  $.scrollIntoViewWithParent = (element) ->
    $element = $(element)
    if $element.length > 0 and $.offScreenWithParent(element)
      $element.scrollParent().scrollTop $element.offset().top - ($element.parent().offset().top)
    return

  return
) jQuery, window
