# <left-nav params="menus: menus, selectedItemId: 'manage', "></left-nav>

# TODO

# - center scroll buttons


class LeftNavFlyoutItem
  constructor: (options) ->
    options = $.extend {
        isNew: false
        isBeta: false
        isAdmin: false
    }, options

    @isNew = ko.asObservable(options.isNew)
    @isBeta = ko.asObservable(options.isBeta)
    @isAdmin = ko.asObservable(options.isAdmin)
    @isSelected = ko.observable(false)
    @hasRibbon = ko.pureComputed () =>
      return @isNew() || @isBeta()
    @ribbonText = ko.pureComputed () =>
      if @isBeta()
        return 'beta'
      if @isNew()
        return 'new'

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

class LeftNavMenuItem
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

    @adminFlyoutItems = ko.observableArray([])
    @normalFlyoutItems = ko.observableArray([])
    ko.computed () =>
      @rawFlayoutItems().forEach (f) =>
        if f.isAdmin
          @adminFlyoutItems.push new LeftNavFlyoutItem(f)
        else
          @normalFlyoutItems.push new LeftNavFlyoutItem(f)



    # Items can either have and location to navigate to or items but not both
    if ko.unwrap(options.href)? and ko.unwrap(options.items)?
      throw "The Menu Item with name '#{@name()}' has defined both a href and
      has Flyout Menu Items. This is not allowed please choose one or the other."

    @templateName = ko.pureComputed () =>
      if !@href()?
        return 'cyclops.leftNav.menuItem.button'
      else
        return 'cyclops.leftNav.menuItem.href'

class LeftNavViewModel
  constructor: (options, element) ->
    options = $.extend {
      menus: [],
      loading: false,
      error: false
    }, options

    # make left-nav sticky
    $leftNav = $(element)
    $window = $(window)
    leftNavOriginalTopPosition = $leftNav.position().top
    calculateLeftNavPosition = () ->
      newTopPosition = leftNavOriginalTopPosition - $window.scrollTop()
      if newTopPosition < 0
        newTopPosition = 0
      $leftNav.css('top': newTopPosition)
    calculateLeftNavPosition()
    $window.on 'scroll', calculateLeftNavPosition

    # Set up Scrolling of many menu Items
    @updateMainMenuScrollIcons = () ->
      $items =  $leftNav.find '.left-nav-menu-items'
      $up = $leftNav.find('.scroll-up')
      $down = $leftNav.find('.scroll-down')

      if $items.scrollTop() + $items.innerHeight() >= $items[0].scrollHeight
        if $down.is ':visible'
          $down.stop().fadeOut()
      else
        if $down.is ':hidden'
          $down.stop().fadeIn()

      if $items.scrollTop() == 0
        $leftNav.find('.scroll-up').fadeOut()
      else
        $leftNav.find('.scroll-up').fadeIn()


    $leftNav.find(".left-nav-menu-items").on 'scroll', @updateMainMenuScrollIcons
    $window.on 'resize', @updateMainMenuScrollIcons



    @scrollDownHandler = (data, event) ->
      $items = $leftNav.find('.left-nav-menu-items')
      $items.scrollTop $items.scrollTop() + 26

    @scrollUpHandler = (data, event) ->
      $items = $leftNav.find('.left-nav-menu-items')
      $items.scrollTop($items.scrollTop() - 26)

    # states
    @isLoading = ko.asObservable(options.loading)
    @hasErrored = ko.asObservable(options.error)



    # create menus
    @rawMenus = ko.asObservable(options.menus)
    renderTimeout = null
    @menus = ko.pureComputed () =>
      result = @rawMenus().reduce (menus, menu) =>
        if menu.href? or (menu.items and ko.unwrap(menu.items).length > 0)
          menus.push new LeftNavMenuItem(menu)
        return menus
      , []
      # we are using a timeout here for performance reason so that its not called
      # 100s of times becuase of the recreation of the entire array.
      if renderTimeout
        window.clearTimeout renderTimeout
      renderTimeout = window.setTimeout @updateMainMenuScrollIcons, 500
      return result

    # selected item
    @SelectedItemId = ko.asObservable(options.selectedItemId)
    selectAnItem = (itemId) =>
      @menus().forEach (m) =>
        if m.id == itemId
          m.isSelected(true)
        else
          m.isSelected(false)
          m.normalFlyoutItems().forEach (f) =>
            if f.id == itemId
              m.isSelected true
              f.isSelected true
            else
              f.isSelected false
          m.adminFlyoutItems().forEach (f) =>
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


    # Auto Close any Flyouts when the user hovers out or clicks outside the leftnav
    $('body > *').not('left-nav').on 'click', () =>
      @menus().forEach (m) -> m.isFlyoutOpen false

    closeTimer = undefined
    $leftNav.hover () =>
      if closeTimer
        window.clearTimeout closeTimer
    , () =>
      closeTimer = window.setTimeout () =>
        @menus().forEach (m) -> m.isFlyoutOpen false
      , 1000
