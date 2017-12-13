ko.bindingHandlers.validationMsg =
  init: (element) ->
    $element = $(element)
    $element.css { display: 'none' }
    $element.removeClass 'hide'
    $element.addClass 'validationMessage'
    return
  update: (element, valueAccessor) ->
    obsv = valueAccessor()
    config = if libraries.knockoutValidation then ko.validation.utils.getConfigOptions(element) else {}
    isModified = false
    isValid = false
    $element = $(element)
    if obsv == null or typeof obsv == 'undefined'
      throw new Error('Cannot bind validationMessage to undefined value. data-bind expression: ' + element.getAttribute('data-bind'))
    # because validation can be called multiple times for each change we want to prevent
    # the animation from starting and stopping or replaying.
    if $element.data('debounce')
      clearTimeout $(element).data('debounce')
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
      $element.data 'debounce', setTimeout((->
        $element.stop().animate {
          opacity: 'hide'
          height: 'hide'
          margin: 'hide'
          padding: 'hide'
        }, 200, (if libraries.jqueryUi then 'easeInOutQuad' else 'swing')
        return
      ), 30)
    else if !isCurrentlyVisible and isVisible
      $element.data 'debounce', setTimeout((->
        $element.stop().animate {
          opacity: 'show'
          height: 'show'
          margin: 'show'
          padding: 'show'
        }, 200, (if libraries.jqueryUi then 'easeInOutQuad' else 'swing')
        return
      ), 30)
    return
