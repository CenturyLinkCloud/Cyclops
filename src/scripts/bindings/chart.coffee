if libraries.chartist
  ko.bindingHandlers.chart =
    init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
      $(element).chart(valueAccessor())
