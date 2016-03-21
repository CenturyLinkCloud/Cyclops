# TODO:
# --- * Expand and collapse
# --- * Dynamic loading of sub items
# --- * Status indicator
# --- * links for items (onClick?)
# --- * search
# --- * Selecting an item
# --- * multiple Icons
# * Override everything aka queue view
# --- * mobile view
# --- * WTF is going on with the close search
# --- * onClick anchor not just svg
# * extra wide

class PaneItemViewModel
  constructor: (item) ->
    rawItem = item

    # TODO: Throw if properties not defined
    @name = rawItem.name
    @href = rawItem.href
    @id = rawItem.id
    #END TODO

    @icons = ko.pureComputed () =>
      return ko.unwrap(rawItem.icons) || ['#icon-question']
    @statusClass = ko.pureComputed () =>
      return ko.unwrap(rawItem.statusClass) || ''
    @items = ko.pureComputed () =>
      ko.unwrap(rawItem.items || []).map (i) ->
        return new PaneItemViewModel(i)
    @isSelected = ko.observable(false)
    @isExpanded = ko.observable(false)
    @isSelected.subscribe (newValue) =>
      if newValue
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
    }, options

    rawItems = ko.asObservable(options.items || [])
    @items = ko.computed () =>
      rawItems().map (i) ->
        return new PaneItemViewModel(i)

    # Selection Logic
    selectedItem = ko.asObservable(options.selectedId);
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

    @itemTemplateName = ko.pureComputed () =>
      return if @isSearching() then options.itemFilteredTemplateName else options.itemTemplateName
    @displayItems = ko.pureComputed () =>
      return if @isSearching() then @filteredItems() else @items()

    # Search Logic
    @searchQuery = ko.observable('')
    @isSearching = ko.pureComputed () =>
      return @searchQuery() != ''
    searchComparer = options.search || (item, query) ->
       return ko.unwrap(item.name).toLowerCase().indexOf(query) > -1
    @showSearchbox = ko.observable(false)
    @toggleSearch = (data, event) =>
      @searchQuery('')
      @showSearchbox !@showSearchbox()
      return
    _doSearch = (item, query, result) ->
      if searchComparer(item, query)
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
