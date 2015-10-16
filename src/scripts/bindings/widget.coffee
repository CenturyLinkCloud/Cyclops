# Creates jQuery UI widget with the give options
# Examples:
#   <input type="submit" value="OK" data-bind='widget: "button"' />
#   <input id='search' data-bind='widget: { name: "autocomplete", options: { source: searchCompletions(), delay: 500 } }, value: searchString' />
#   <input id='search' data-bind='widget: { name: "autocomplete", disabled: trueyOrFalsey, value: searchString' />

_getWidgetBindings = (element, valueAccessor, allBindingsAccessor) ->
  value = valueAccessor()
  myBinding = ko.unwrap(value)
  allBindings = allBindingsAccessor()
  if typeof myBinding == 'string'
    myBinding = 'name': myBinding
  widgetName = myBinding.name
  widgetOptions = myBinding.options
  disabled = myBinding.disabled
  enabled = myBinding.enabled
  # Sanity check: can't directly check that it's truly a _widget_, but
  # can at least verify that it's a defined function on jQuery:
  if typeof $.fn[widgetName] != 'function'
    throw new Error('widget binding doesn\'t recognize \'' + widgetName + '\' as jQuery UI widget')
  # Sanity check: don't confuse KO's 'options' binding with jqueryui binding's 'options' property
  if allBindings.options and !widgetOptions and element.tagName != 'SELECT'
    throw new Error('widget binding options should be specified like this:\ndata-bind=\'widget: {name:"' + widgetName + '", options:{...} }\'')
  {
    widgetName: widgetName
    widgetOptions: widgetOptions
    disabled: disabled
    enabled: enabled
  }

ko.bindingHandlers.widget = update: (element, valueAccessor, allBindingsAccessor) ->
  widgetBindings = _getWidgetBindings(element, valueAccessor, allBindingsAccessor)

  updateDisabled = (disabled) ->
    methodName = if disabled then 'disable' else 'enable'
    $(element)[widgetBindings.widgetName] methodName
    return

  subscribeToDisabledIfSet = (disabled) ->
    if disabled == undefined or disabled == null
      return
    if ko.isObservable(disabled)
      disabled.subscribe (newValue) ->
        updateDisabled newValue
        return
    updateDisabled ko.unwrap(disabled)
    return

  subscribeToEnabledIfSet = (enabled) ->
    if enabled == undefined or enabled == null
      return
    if ko.isObservable(enabled)
      enabled.subscribe (newValue) ->
        updateDisabled !newValue
        return
    updateDisabled !ko.unwrap(enabled)
    return

  $(element)[widgetBindings.widgetName] widgetBindings.widgetOptions
  subscribeToDisabledIfSet widgetBindings.disabled
  subscribeToEnabledIfSet widgetBindings.enabled
  return
