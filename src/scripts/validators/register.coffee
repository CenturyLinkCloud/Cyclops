if libraries.knockoutValidation
  # will be included after all the validators and cause them to be included
  ko.validation.registerExtenders()

  # For some crazy reason knockout-validation does not support observable
  # min and max so we are going to override them. This is a simpler implementation
  # but for what we use it for it will work. They have to come after registerExtenders
  # so that they are correctly overrode

  ko.validation.rules['min'] =
    validator: (val, min) ->
      isEmptyVal(val) or val >= ko.unwrap(min)
    message: 'Please enter a value greater than or equal to {0}.'
  ko.validation.rules['max'] =
    validator: (val, max) ->
      isEmptyVal(val) or val <= ko.unwrap(max)
    message: 'Please enter a value less than or equal to {0}.'
