_scrollIntoView = (element) ->
  $element = $(element)
  $parent = $element.parents('.scroll-area')
  parentTop = $parent.offset().top
  elementTop = $element.offset().top
  parentBottom = parentTop + $parent.height();
  elementBottom = elementTop + $element.outerHeight();
  if elementBottom > parentBottom
    $element[0].scrollIntoView(false)
  else if elementTop < parentTop
    $element[0].scrollIntoView()
  return


ko.bindingHandlers.scrollTo = update: (element, valueAccessor) ->
  value = ko.unwrap(valueAccessor()) or false
  if value
    _scrollIntoView(element)
