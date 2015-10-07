$.fn.passwordStrength = (options) ->
  calculatePasswordStrength = (password) ->
    upper = /[A-Z]/
    lower = /[a-z]/
    number = /[0-9]/
    special = /[\~\!\@\#\$\%\^\&\*\_\-\+\=\|\\\(\)\{\}\[\]\:<>\,\.\?\/]/
    charTypes = 0
    strength = 0
    if lower.test(password)
      charTypes++
    if upper.test(password)
      charTypes++
    if number.test(password)
      charTypes++
    if special.test(password)
      charTypes++
    if password.length < 8
      strength = 0
    else if charTypes < 3
      strength = 1
    else if password.length == 8 and charTypes == 3
      strength = 2
    else if password.length <= 9 or charTypes == 3
      strength = 3
    else
      strength = 4
    strength

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
      strength = calculatePasswordStrength($input.val())
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
