# Works like the default visible binding but fades the content in and out
# Examples:
#   <div data-bind='fadeVisible: trueFalseObservable' />
ko.bindingHandlers.fadeVisible = update: (element, valueAccessor) ->
  value = ko.unwrap(valueAccessor()) or false
  shouldShow = false
  options = duration: 500
  isCurrentlyVisible = element.style.display != 'none'
  afterAnimation = valueAccessor().afterAnimation
  if typeof value == 'object'
    if value.visible
      shouldShow = ko.unwrap(value.visible)
    else
      throw new Error('You need to have a visible value... ')
    options.duration = value.duration or options.duration
    options = $.extend(options, value.options or {})
  else
    shouldShow = value
    # we treat this a boolish value
  if shouldShow and !isCurrentlyVisible
    $(element).stop().fadeIn options, ->
      if typeof afterAnimation == 'function'
        afterAnimation.call()
      return
  else if !shouldShow and isCurrentlyVisible
    if value.fadeOut == undefined or value.fadeOut
      $(element).stop().fadeOut options, ->
        if typeof afterAnimation == 'function'
          afterAnimation.call()
        return
    else
      element.style.display = 'none'
  return
