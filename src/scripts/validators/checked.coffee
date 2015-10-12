ko.validation.rules.checked =
  validator: (value) ->
    ! !ko.unwrap(value)
  message: 'You must agree.'
