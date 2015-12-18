###
# renders href attrribute
# @param title to be displayed
# @example <a data-bind='title: model.title'></a>
###

ko.bindingHandlers.title = update: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
  ko.bindingHandlers['attr']['update'] element, (->
    { title: valueAccessor() }
  ), allBindings, viewModel, bindingContext
