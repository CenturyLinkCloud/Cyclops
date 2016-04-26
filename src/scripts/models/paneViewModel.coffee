class PaneItemViewModel
  constructor: (item) ->
    @rawItem = item

    @id = @rawItem.id
    if !@id?
      throw 'A Pane Item must have an id.'

    @name = @rawItem.name
    if !ko.unwrap(@name)?
      throw 'A Pane Item must have a name.'

    @href = @rawItem.href
    if !ko.unwrap(@href)?
      throw 'A Flyout Menu Item must have a href.'

    @icons = ko.pureComputed () =>
      return ko.unwrap(@rawItem.icons) || []
    @statusClass = ko.pureComputed () =>
      return ko.unwrap(@rawItem.statusClass) || ''
    @items = ko.pureComputed () =>
      ko.unwrap(@rawItem.items || []).map (i) ->
        return new PaneItemViewModel(i)

    @isSelected = ko.observable(false)
    @isExpanded = ko.observable(false)
    @isChildSelected = ko.computed () =>
      result = false
      @items().forEach (i) ->
        if i.isSelected() || i.isChildSelected()
          result = true
      return result

    ko.computed () =>
      if @isSelected()  || @isChildSelected()
        @isExpanded(true)

    toggleExpanded = () =>
      @isExpanded !@isExpanded()
    @hasItems = ko.pureComputed () =>
      return helpers.hasItems(@items)
    @caretIcon = ko.pureComputed () =>
      if @hasItems
        return if @isExpanded() then '#icon-caret-down' else '#icon-caret-right'
      else
        return ''

    @onClick = (data, event) =>
      if $(event.target).is('use, svg')
        toggleExpanded()
        return false
      return true



class PaneViewModel
  constructor: (options, element) ->
    options = $.extend {
      itemTemplateName: 'cyclops.paneItem'
      itemFilteredTemplateName: 'cyclops.paneItemFiltered'
      emptyTemplateName: 'cyclops.paneEmpty'
      loadingTemplateName: 'cyclops.paneItemsLoading'
      loading: false
      headerTemplateName: 'cyclops.paneHeader'
      maxSearchResults: 20
      searchComparer: (item, query) ->
         return ko.unwrap(item.name).toLowerCase().indexOf(query) > -1
    }, options



    @rawItems = ko.asObservable(options.items || [])
    @items = ko.computed () =>
      @rawItems().map (i) ->
        return new PaneItemViewModel(i)

    @bodyTemplateName = ko.pureComputed () =>
      if ko.unwrap(options.loading)
        return options.loadingTemplateName
      else if @rawItems().length < 1
        return options.emptyTemplateName
      else
        return 'cyclops.paneForeach'

    # Selection Logic
    selectedItem = ko.asObservable(options.selectedItemId);
    _doSelection = (item, id) ->
      item.isSelected(item.id == id)
      item.items().forEach (i) -> _doSelection(i, id)
    ko.computed () =>
       @items().forEach (i) -> _doSelection(i, selectedItem())

    # Global expand and collapse
    _doExpandOrCollapse = (item, shouldExpand) ->
      item.isExpanded(shouldExpand)
      item.items().forEach (i) -> _doExpandOrCollapse(i, shouldExpand)
    expandOrCollapse = (shouldExpand) =>
      @items().forEach (i) -> _doExpandOrCollapse(i, shouldExpand)
    @expandAll = () ->
      expandOrCollapse(true)
    @collapseAll = () ->
      expandOrCollapse(false)

    # Templates
    @headerTemplateName = options.headerTemplateName
    @itemTemplateName = ko.pureComputed () =>
      return if @isSearching() then options.itemFilteredTemplateName else options.itemTemplateName

    @displayItems = ko.pureComputed () =>
      if @isSearching()
        return @filteredItems().slice(0, options.maxSearchResults)
      else @items()

    @paneSearchMessage = ko.pureComputed () =>
      maxLength = ko.unwrap options.maxSearchResults
      if @isSearching() && maxLength < @filteredItems().length
        return "showing #{maxLength} of #{@filteredItems().length} results."
      else if @filteredItems().length == 0
        return 'no results'
      else
        return 'showing all results'


    # Search Logic
    @searchQuery = ko.observable('')
    @isSearching = ko.pureComputed () =>
      return @searchQuery() != ''
    @showSearchbox = ko.observable(false)
    @toggleSearch = (data, event) =>
      @searchQuery('')
      @showSearchbox !@showSearchbox()
      return
    _doSearch = (item, query, result) ->
      if options.searchComparer(item, query)
        result.push(item)
      item.items().forEach (i) -> _doSearch(i, query, result)
    @filteredItems = ko.pureComputed () => 
      result = [];
      if @isSearching()
        @items().forEach (i) =>
          _doSearch(i, @searchQuery().toLowerCase(), result)
      return result

    # Mobile View
    @togglePane = () ->
      $(element).toggleClass 'pane-expanded'

    $(element).affix()
