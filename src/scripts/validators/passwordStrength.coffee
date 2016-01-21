if libraries.knockoutValidation
  ko.validation.rules.passwordStrength =
    validator: (val, options) ->
      options = $.extend({
        requiredStrength: 3
        dissallowedCharacters: []
      }, options)
      if !val
        return true
      strength = helpers.calculatePasswordStrength(val)
      badCharacters = helpers.containsAny(val, options.dissallowedCharacters)
      if badCharacters.length > 0
        many = badCharacters.length > 1
        @message = 'The character' + (if many then 's' else '') + ' \'' + badCharacters.join('\', \'') + '\' ' + (if many then 'are' else 'is') + ' not allowed.'
      else if strength < options.requiredStrength
        if options.requiredStrength >= 4
          @message = 'A password must be at least 9 characters and contain all of the following: ' + '<ul>' + '<li>uppercase letters</li>' + '<li>lowercase letters</li>' + '<li>numbers</li>' + '<li>symbols</li>' + '</ul>'
        else if options.requiredStrength >= 3
          @message = 'A password must be at least 9 characters and contain at least 3 of the following: ' + '<ul>' + '<li>uppercase letters</li>' + '<li>lowercase letters</li>' + '<li>numbers</li>' + '<li>symbols</li>' + '</ul>'
        else if options.requiredStrength >= 2
          @message = 'A password must be at least 8 characters and contain at least 3 of the following: ' + '<ul>' + '<li>uppercase letters</li>' + '<li>lowercase letters</li>' + '<li>numbers</li>' + '<li>symbols</li>' + '</ul>'
        else
          @message = 'A password must be at least 8 characters.'
      strength >= options.requiredStrength and badCharacters.length < 1
    message: ''
