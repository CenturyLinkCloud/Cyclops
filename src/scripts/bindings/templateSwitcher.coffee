ko.bindingHandlers.templateSwitcher = update: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
  binding = ko.unwrap(valueAccessor())
  isLoading = ko.unwrap(binding.loading)
  hasErrored = ko.unwrap(binding.error) or false
  value = ko.unwrap(binding.value)
  templateInfo = binding.templates or {}
  loadingTemplate = templateInfo.loading or 'cyclops.templateSwitcherLoadingTemplate'
  noContentTemplate = templateInfo.empty or 'cyclops.templateSwitcherEmptyTemplate'
  errorTemplate = templateInfo.error or 'cyclops.templateSwitcherErrorTemplate'
  displayTemplate = templateInfo.display
  if displayTemplate == undefined or displayTemplate == null
    throw 'You Must define a display template. e.g. templates: { display: \'myTemplate\' }'
  templateToRender = undefined
  if isLoading
    templateToRender = loadingTemplate
  else if hasErrored
    templateToRender = errorTemplate
  else
    if $.isArray(value) and value.length < 1
      templateToRender = noContentTemplate
    else if !value
      # empty string
      templateToRender = noContentTemplate
    else
      templateToRender = displayTemplate

  newValueAccessor = ->
    templateToRender

  ko.bindingHandlers['template']['update'] element, newValueAccessor, allBindings, viewModel, bindingContext
  return
ko.virtualElements.allowedBindings.templateSwitcher = true
