class GroupPickerViewModel
  constructor: (options) ->
    options = options || {}

    @defaultShouldShow = (group)->
      if group.type?
        return ko.unwrap(group.type) == 'default'
      else
        return true

    @controlName = 'group_picker_' + Math.random().toString(36).substr(2, 9)

    @shouldShow = if options.shouldShow? then options.shouldShow else @defaultShouldShow
    @groups = ko.asObservableArray if options.groups? then options.groups else []
    @isLoading = ko.asObservable if options.isLoading? then options.isLoading else false
    @loadingHtmlMessage = ko.asObservable if options.loadingHtmlMessage? then options.loadingHtmlMessage else "Fetching Groups&hellip;"
    @emptyHtmlMessage = ko.asObservable if options.emptyHtmlMessage? then options.emptyHtmlMessage else "No Groups"
    @selected =  ko.asObservable options.selectedGroup
