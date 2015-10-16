###
# renders when the collection is empty. Can be used
# on with virtual elements.
# @param anyArray any array observable or not
# @example <!-- ko empty: collection -->content<!-- /ko -->
###

ko.bindingHandlers.empty = init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
  ko.bindingHandlers['if']['init'] element, (->
    ko.computed ->
      !helpers.hasItems(valueAccessor())
  ), allBindings, viewModel, bindingContext
ko.virtualElements.allowedBindings.empty = true
