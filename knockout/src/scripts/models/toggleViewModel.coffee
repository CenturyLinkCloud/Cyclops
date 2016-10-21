#TODO 1. disabled
#     2. subscribe to value change
class ToggleViewModel
  constructor: (options, element) ->
    options = options || {}
    @value = ko.asObservable if options.value? then options.value else false

    $(element).find("input").toggle({
      affirmativeText: options.affirmativeText
      negativeText: options.negativeText
      defaultChecked: @value()
      onChange: (checked) =>
        @value(checked)
    })
