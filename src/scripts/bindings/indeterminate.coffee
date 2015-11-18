###
# renders href attrribute
# @param true or false to add the indeterminate property
# @example <input type='checkbox' data-binding='indeterminate: model.indeterminate'></a>
###

ko.bindingHandlers.indeterminate = update: (element, valueAccessor) ->
  value = ko.unwrap valueAccessor()
  $(element).prop "indeterminate", value
