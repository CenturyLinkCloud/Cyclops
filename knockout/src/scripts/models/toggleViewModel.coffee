class ToggleViewModel
  constructor: (options) ->
    options = options || {}
    @affirmativeText = ko.asObservable if options.affirmativeText? then options.affirmativeText else 'yes'
    @negativeText = ko.asObservable if options.negativeText? then options.negativeText else 'no'
    @value = ko.asObservable if options.value? then options.value else false
    @disabled = ko.asObservable if options.disabled? then options.disabled else false
