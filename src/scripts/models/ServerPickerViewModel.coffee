class ServerPickerGroupViewModel
  # TODO
  #  - Multi vs single select

  constructor: (group, options) ->
    @rawGroup = group

    @state = ko.observable('unchecked')

    @isChecked = ko.computed () =>
      return @state() == 'checked'

    @isIndeterminate = ko.computed () =>
      return @state() == 'indeterminate'

    @selectable = ko.computed () =>
      return @state() != 'notSelectable'

    @rawServers = ko.asObservableArray if group.servers? then group.servers else []

    @allRawGroups = ko.asObservableArray if group.groups? then group.groups else []

    @rawGroups = ko.computed () =>
      return @allRawGroups().filter options.shouldShowGroup

    @groups = ko.computed () =>
      return @rawGroups().map (g) ->
        return new ServerPickerGroupViewModel g, options

    @selectableGroups = ko.computed () =>
      return @groups().filter (g) ->
        return g.state() != 'notSelectable'

    @servers = ko.computed () =>
      return @rawServers().map (s) =>
        return new  ServerPickerServerViewModel s, options

    @selectableServers = ko.computed () =>
      return @servers().filter (s) ->
        return s.selectable()

    @setServersAndGroups = (checked) ->
      @selectableGroups().forEach (g) =>
        g.setServersAndGroups checked
      @servers().forEach (s) =>
        if s.selectable()
          s.isChecked checked

    @clickHandler = (group, event) =>
      checkbox = $(event.target)
      checked = checkbox.prop 'checked'
      @setServersAndGroups(checked)
      return true

    @title = ko.computed () =>
      if @selectable()
        return options.getGroupTitle(@rawGroup)
      else
        return 'Groups that have no decendent server are not selectable.'

    @allServers = ko.computed () =>
      servers = @selectableServers()
      @selectableGroups().forEach (g) ->
        servers = servers.concat g.allServers()
        return
      return servers

    _doesntMatter = ko.computed () =>
      if not options.multiSelect()
        return

      checkedGroups = []
      indeterminateGroups = []
      uncheckedGroups = []
      selectableGroups = @selectableGroups()
      selectableServers = @selectableServers()

      selectedServers = selectableServers.filter (s) ->
        return s.isChecked()

      selectableGroups.forEach (g) =>
        if g.state.peek() == 'checked'
          checkedGroups.push g
        else if g.state.peek() == 'indeterminate'
          indeterminateGroups.push g
        else
          uncheckedGroups.push g

      if selectableGroups.length == 0 and selectableServers.length == 0
        @state('notSelectable')

      else if uncheckedGroups.length == selectableGroups.length and selectedServers.length == 0
        @state('unchecked')

      else if checkedGroups.length == selectableGroups.length  and selectedServers.length == selectableServers.length
        @state('checked')

      else if checkedGroups.length > 0 || selectedServers.length > 0
        @state('indeterminate')

      return


class ServerPickerServerViewModel
  constructor: (server, options) ->
    @rawServer = server

    @displayName = ko.asObservable if @rawServer.displayName? then @rawServer.displayName else @rawServer.name

    @isChecked = ko.observable(@rawServer.isChecked)

    @title = ko.computed () =>
      return options.getServerTitle(@rawServer)

    @selectable = ko.computed () =>
      return options.isServerSelectable(@rawServer)


class ServerPickerViewModel
  constructor: (options) ->
    options = options || {}

    @controlName = 'server_picker_' + Math.random().toString(36).substr(2, 9)

    @defaultShouldShowGroup = (group)->
      if group.type?
        return ko.unwrap(group.type) == 'default'
      else
        return true

    @defaultIsServerSelectable = (server) ->
      return true

    @defaultGetServerTitle = (server) ->
      return server.description

    @defaultGetGroupTitle = (group) ->
      return group.description

    @defaultGetServerIcon = (state) ->
      state = ko.unwrap(state)
      if state == 'archived'
        return '#icon-question'
      else if state == 'queuedForArchive'
        return '#icon-question'
      else if state == 'deleted'
        return '#icon-question'
      else if state == 'queuedForDelete'
        return '#icon-question'
      else if state == 'queuedForRestore'
        return '#icon-question'
      else if state == 'underConstruction'
        return '#icon-question'
      else if state == 'template'
        return '#icon-queue'

      else if state == 'noDetails'
        return '#icon-question'
      else if state == 'maintenanceMode'
        return '#icon-maintenance'
      else if state == 'stopped'
        return '#icon-stop'
      else if state == 'started'
        return '#icon-play'
      else if state == 'paused'
        return '#icon-pause'
      else
        return '#icon-question'

    @allGroups = ko.asObservableArray if options.groups? then options.groups else []

    @isLoading = ko.asObservable if options.isLoading? then options.isLoading else false

    @loadingHtmlMessage = ko.asObservable if options.loadingHtmlMessage? then options.loadingHtmlMessage else 'Fetching Servers&hellip;'

    @emptyHtmlMessage = ko.asObservable if options.emptyHtmlMessage? then options.emptyHtmlMessage else 'No Servers'

    @selected =  ko.asObservableArray options.selectedServers

    @getServerIcon = if options.getServerIcon? then options.getServerIcon else @defaultGetServerIcon

    @shouldShowGroup = if options.shouldShowGroup? then options.shouldShowGroup else @defaultShouldShowGroup

    @isServerSelectable = if options.isServerSelectable? then options.isServerSelectable else @defaultIsServerSelectable

    @getServerTitle = if options.getServerTitle? then options.getServerTitle else @defaultGetServerTitle

    @getGroupTitle = if options.getGroupTitle? then options.getGroupTitle else @defaultGetGroupTitle

    @multiSelect = ko.asObservable if options.multiSelect? then options.multiSelect else true

    @templateName = ko.pureComputed () =>
      return if @multiSelect() then 'cyclops.serverPicker.group.multi' else 'cyclops.serverPicker.group.single'

    @groups = ko.computed () =>
      filteredGroups = @allGroups().filter @shouldShowGroup
      return filteredGroups.map (g) =>
        return new ServerPickerGroupViewModel g, {
          shouldShowGroup: @shouldShowGroup
          getGroupTitle: @getGroupTitle
          isServerSelectable: @isServerSelectable
          getServerTitle: @getServerTitle
          multiSelect: @multiSelect
        }

    # Do this once at the beging to set the default selected servers.
    # We assume the server will be selectable, if not then it is basically
    # lost as the computed below will kick in and set the selected items to
    # only those that are selectable and checked.
    @groups().forEach (g) =>
      g.allServers().forEach (s) =>
        if @selected().indexOf(s.rawServer) > -1
          s.isChecked true
        return
      return

    _doesntMatter = ko.computed () =>
      if not @multiSelect()
        return
      checkedServers = []
      @groups().forEach (g) =>
        checkedServers = checkedServers.concat g.allServers().filter (s) ->
          return s.isChecked()
        return
      checkedServers = checkedServers.map (s) ->
        s.rawServer
      @selected(checkedServers)
      return

    _doesntMatter.extend { rateLimit: 50 }
