###
# renders href attrribute
# @param url the url to be placed in the href
# @example <a data-bind='href: model.url'></a>
###

ko.bindingHandlers.href = update: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
  ko.bindingHandlers['attr']['update'] element, (->
    { href: valueAccessor() }
  ), allBindings, viewModel, bindingContext
