###
# renders when the collection has items. Can be used
# on with virtual elements.
# @param anyArray any array observable or not
# @example <!-- ko any: collection -->content<!-- /ko -->
###

ko.bindingHandlers.any = init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
  ko.bindingHandlers['if']['init'] element, (->
    ko.computed ->
      helpers.hasItems valueAccessor()
  ), allBindings, viewModel, bindingContext
ko.virtualElements.allowedBindings.any = true
