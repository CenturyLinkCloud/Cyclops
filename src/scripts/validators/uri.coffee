if libraries.knockoutValidation
  ko.validation.rules.uri =
    validator: (value, options) ->
      options = $.extend({}, options)
      scheme = options.scheme
      pattern = value.match(/(https?|ftp)\:\/\/([a-z0-9\-.]*)\.([a-z]{2,3})(\:[0-9]{2,5})?(\/([a-z0-9+\$_\-]\.?)+)*\/?/i)
      type = if scheme then value.substring(0, value.indexOf(':')).toLowerCase() == scheme.toLowerCase() else true
      return pattern and type
    message: 'Please enter a valid uri'
