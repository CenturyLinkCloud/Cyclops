_offScreenWithParent = (element) ->
  $element = $(element)
  parentViewTop = $element.parents('.scroll-area').scrollTop()
  parentViewBottom = parentViewTop + $element.parent().height()
  elemTop = $element.offset().top
  elemBottom = elemTop + $element.height()
  elemBottom > parentViewBottom or elemTop < parentViewTop

_scrollIntoView = (element) ->
  $element = $(element)
  if $element.length > 0 and _offScreenWithParent(element)
    $element[0].scrollIntoView(false)
  return


ko.bindingHandlers.scrollTo = update: (element, valueAccessor) ->
  value = ko.unwrap(valueAccessor()) or false
  if value
    _scrollIntoView($(element))
