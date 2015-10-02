# Works like the default visible binding but slides & fades the content in and out
# Examples:
#   <div data-bind='fadeSlide: trueFalseObservable' />
ko.bindingHandlers.fadeSlide = update: (element, valueAccessor) ->
  value = ko.unwrap(valueAccessor()) or false
  shouldShow = false
  duration = 300
  isCurrentlyVisible = $(element).css('display') != 'none'
  afterAnimation = valueAccessor().afterAnimation
  if typeof value == 'object'
    if value.visible
      shouldShow = ko.unwrap(value.visible)
    else
      throw new Error('You need to have a visible value... ')
    duration = value.duration or duration
  else
    shouldShow = value
    # we treat this a boolish value
  if shouldShow and !isCurrentlyVisible
    $(element).stop(true, true).fadeIn(
      duration: duration
      queue: false).css('display', 'none').slideDown duration, ->
      if typeof afterAnimation == 'function'
        afterAnimation.call()
      return
  else if !shouldShow and isCurrentlyVisible
    $(element).stop(true, true).fadeOut(
      duration: duration
      queue: false).slideUp duration, ->
      if typeof afterAnimation == 'function'
        afterAnimation.call()
      return
  return
