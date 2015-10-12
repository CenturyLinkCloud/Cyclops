ko.validation.rules.notEmpty =
  hasItems: (data) ->
    value = ko.unwrap(data)
    result = false
    if value.length and value.length > 0
      result = true
    result
  validator: (value) ->
    @hasItems value
  message: 'Must not be empty'
