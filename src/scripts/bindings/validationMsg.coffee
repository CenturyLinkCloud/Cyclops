ko.bindingHandlers.validationMsg =
  init: (element) ->
    $(element).addClass 'validationMessage'
    return
  update: (element, valueAccessor) ->
    obsv = valueAccessor()
    config = ko.validation.utils.getConfigOptions(element)
    isModified = false
    isValid = false
    $element = $(element)
    if obsv == null or typeof obsv == 'undefined'
      throw new Error('Cannot bind validationMessage to undefined value. data-bind expression: ' + element.getAttribute('data-bind'))
    # because validation can be called multiple times for each change we want to prevent
    # the animation from starting and stopping or replaying.
    if $element.data('debounce')
      window.clearTimeout $(element).data('debounce')
    isModified = obsv.isModified and obsv.isModified()
    isValid = obsv.isValid and obsv.isValid()
    error = null
    if !config.messagesOnModified or isModified
      error = if isValid then null else obsv.error
    isVisible = if !config.messagesOnModified or isModified then !isValid else false
    isCurrentlyVisible = element.style.display != 'none'
    if config.allowHtmlMessages
      ko.utils.setHtml element, error
    else
      ko.bindingHandlers.text.update element, ->
        error
    if isCurrentlyVisible and !isVisible
      $element.data 'debounce', window.setTimeout((->
        $element.stop().animate {
          opacity: 'hide'
          height: 'hide'
          margin: 'hide'
          padding: 'hide'
        }, 200, 'easeInOutQuad'
        return
      ), 30)
    else if !isCurrentlyVisible and isVisible
      $element.data 'debounce', window.setTimeout((->
        $element.stop().animate {
          opacity: 'show'
          height: 'show'
          margin: 'show'
          padding: 'show'
        }, 200, 'easeInOutQuad'
        return
      ), 30)
    return
