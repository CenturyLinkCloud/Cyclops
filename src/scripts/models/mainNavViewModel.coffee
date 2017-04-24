# <main-nav params="menus: menus, selectedItemId: 'manage', "></main-nav>

class MainNavFlyoutItem
  constructor: (options) ->
    options = $.extend {
        flag: ''
    }, options


    @isSelected = ko.observable(false)

    @hasRibbon = ko.pureComputed () =>
      return !!options.flag

    @ribbonText = ko.pureComputed () =>
      return options.flag

    @ribbonCssClass = ko.pureComputed () =>
      if options.flag == 'beta'
        return 'ribbon-beta'
      else
        return ''

    @id = options.id
    if !@id?
      throw 'A Flyout Menu Item must have an id.'
    @name = ko.asObservable(options.name)
    if !@name()?
      throw 'A Flyout Menu Item must have a name.'
    @href = ko.asObservable(options.href)
    if !@href()?
      throw 'A Flyout Menu Item must have a href.'
    @description = ko.asObservable(options.description)

class MainNavMenuItem
  toggleFlyout: (item) ->
    item.isFlyoutOpen !item.isFlyoutOpen()

  constructor: (options) ->
    options = $.extend {
        iconId: '#icon-circle-o'
        name: 'unknown'
    }, options

    @id = options.id
    if !@id?
      throw "A Menu Item must provide an ID."

    @name = ko.asObservable(options.name)
    if !@name()?
      throw "A Menu Item must provide a name."

    @icon = ko.asObservable(options.iconId)

    @isFlyoutOpen = ko.observable(false)

    @isSelected = ko.observable(false)

    @href = ko.asObservable(options.href)

    @rawFlayoutItems = ko.asObservableArray(options.items)

    @flyoutItems = ko.observableArray([])
    ko.computed () =>
      @flyoutItems @rawFlayoutItems().map (f) -> new MainNavFlyoutItem(f)

    # Items can either have and location to navigate to or items but not both
    if ko.unwrap(options.href)? and ko.unwrap(options.items)?
      throw "The Menu Item with name '#{@name()}' has defined both a href and
      has Flyout Menu Items. This is not allowed please choose one or the other."

    @templateName = ko.pureComputed () =>
      if !@href()?
        return 'cyclops.mainNav.menuItem.button'
      else
        return 'cyclops.mainNav.menuItem.href'

class MainNavViewModel
  constructor: (options, element) ->
    options = $.extend {
      menus: [],
      loading: false,
      error: false
    }, options

    $mainNav = $(element)

    # states
    @isLoading = ko.asObservable(options.loading)
    @hasErrored = ko.asObservable(options.error)

    # create menus
    @rawMenus = ko.asObservable(options.menus)
    renderTimeout = null
    @menus = ko.pureComputed () =>
      @rawMenus().reduce (menus, menu) =>
        if menu.href? or (menu.items and ko.unwrap(menu.items).length > 0)
          menus.push new MainNavMenuItem(menu)
        menus
      , []

    # selected item
    @SelectedItemId = ko.asObservable(options.selectedItemId)
    selectAnItem = (itemId) =>
      @menus().forEach (m) =>
        if m.id == itemId
          m.isSelected(true)
        else
          m.isSelected(false)
          m.flyoutItems().forEach (f) =>
            if f.id == itemId
              m.isSelected true
              f.isSelected true
            else
              f.isSelected false
    @SelectedItemId.subscribe selectAnItem
    @menus.subscribe () =>
      selectAnItem @SelectedItemId()
    selectAnItem @SelectedItemId()

    @selectFlyout = (menu) =>

      previousState = menu.isFlyoutOpen()
      @menus().forEach (m) -> m.isFlyoutOpen false
      if(!previousState)
        menu.isFlyoutOpen !previousState
      $(".main-nav-flyout-menu.open .main-nav-flyout-menu-items li:first-child a").focus()
      return

    # Auto Close any Flyouts when the user hovers out or clicks outside the mainNav
    $('body > *').not('main-nav').on 'click', () =>
      @menus().forEach (m) -> m.isFlyoutOpen false

    closeTimer = undefined
    $mainNav.hover () =>
      if closeTimer
        window.clearTimeout closeTimer
    , () =>
      closeTimer = window.setTimeout () =>
        @menus().forEach (m) -> m.isFlyoutOpen false
      , 1000

    $mainNav.addClass 'loaded'
