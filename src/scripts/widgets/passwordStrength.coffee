$.fn.passwordStrength = (options) ->
  $(this).each (idx, input) ->
    options = $.extend({}, options)
    $input = $(input)
    container = if options.messageContainer then $(options.messageContainer) else $('<p class=\'password-strength\'></p>')
    messageBlock = $('<span class=\'strength\'></span>')
    container.text 'password strength: '
    container.append messageBlock
    if !options.messageContainer
      container.insertAfter $input
    strength = 0
    $input.on 'input', ->
      strength = helpers.calculatePasswordStrength($input.val())
      messageBlock.removeClass 'strong'
      messageBlock.removeClass 'good'
      messageBlock.removeClass 'weak'
      if $input.val().length < 1
        messageBlock.text ''
      else if strength >= 4
        messageBlock.text 'Strong'
        messageBlock.addClass 'strong'
      else if strength >= 3
        messageBlock.text 'Good'
        messageBlock.addClass 'good'
      else
        messageBlock.text 'Weak'
        messageBlock.addClass 'weak'
      return
    return
  return
