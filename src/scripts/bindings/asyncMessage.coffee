ko.bindingHandlers.asyncMessage =
  init: (element, valueAccessor) ->
    options =
      validating: 'checking availability...'
      valid: 'available'
    possible = valueAccessor()
    $element = $(element)
    if ko.isObservable(possible)
      $.extend options, value: possible
    else
      $.extend options, possible
    $element.addClass 'async-message'
    $element.html '<span class=\'validating hide\'>' + ko.unwrap(options.validating) + '</span>' + '<span class=\'valid hide\'>' + ko.unwrap(options.valid) + '</span>'
    return
  update: (element, valueAccessor) ->
    $element = $(element)
    possible = valueAccessor()
    observable = undefined
    if ko.isObservable(possible)
      observable = possible
    else
      observable = possible.value
      # find a better was to do this..
      if ko.isObservable(possible.validating)
        $element.find('.validating').html possible.validating()
      if ko.isObservable(possible.valid)
        $element.find('.valid').html possible.valid()
    # hide any visible messages
    $element.find('.validating, .valid').hide()
    # show one if appropriate
    if observable.isValidating()
      $element.find('.validating').show()
    else if observable.isValid()
      $element.find('.valid').show()
    return
