ko.bindingHandlers.console = update: (element, valueAccessor) ->
  console.log ko.unwrap(valueAccessor())
  return
ko.virtualElements.allowedBindings.console = true
