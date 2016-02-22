# <left-nav params="menus: menus, selectedMenu: 'manage', "></left-nav>

# TODO
# - may need to look at window resize and recalc scroll buttons
# - scrolling on iphone is fucked up

# - container margin removes centering
# - observable for selectedItem
# - system admin flyout items
# - loading state when page first loads and fetching menu items?

class LeftNavFlyoutItem
  constructor: (options) ->
    options = $.extend {
        isNew: false
        isBeta: false
    }, options

    @isNew = ko.asObservable(options.isNew)
    @isBeta = ko.asObservable(options.isBeta)
    @hasRibbon = ko.pureComputed () =>
      return @isNew() || @isBeta()
    @ribbonText = ko.pureComputed () =>
      if @isBeta()
        return 'beta'
      if @isNew()
        return 'new'

    @id = ko.asObservable(options.id)
    if !@id()?
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
    item.isSelected !item.isSelected()

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
    @isSelected = ko.observable(false);

    @href = ko.asObservable(options.href)

    @rawFlayoutItems = ko.asObservableArray(options.items)
    @flayoutItems = ko.pureComputed () =>
      return @rawFlayoutItems().map (f) ->
        return new LeftNavFlyoutItem(f)


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
      menus: []
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
    updateMainMenuScrollIcons = () ->
      $items =  $leftNav.find '.items'

      if $items.scrollTop() + $items.innerHeight() >= $items[0].scrollHeight
        $leftNav.find('.scroll-down').fadeOut()
      else
        $leftNav.find('.scroll-down').fadeIn()
      if $items.scrollTop() == 0
        $leftNav.find('.scroll-up').fadeOut()
      else
        $leftNav.find('.scroll-up').fadeIn()

    updateMainMenuScrollIcons()
    $leftNav.find(".items").on 'scroll', updateMainMenuScrollIcons

    @scrollDownHandler = (data, event) ->
      $items = $leftNav.find('.items')
      $items.scrollTop $items.scrollTop() + 26

    @scrollUpHandler = (data, event) ->
      $items = $leftNav.find('.items')
      $items.scrollTop($items.scrollTop() - 26)

    # create menus
    @rawMenus = ko.asObservable(options.menus)
    @menus = ko.pureComputed () =>
      return @rawMenus().reduce (menus, menu) =>
        if menu.href? or (menu.items and ko.unwrap(menu.items).length > 0)
          menus.push new LeftNavMenuItem(menu)
        return menus
      , []

    @selectFlyout = (menu) =>
      previousState = menu.isSelected()
      @menus().forEach (m) -> m.isSelected false
      if(!previousState)
        menu.isSelected !previousState


    # Auto Close any Flyouts when the user hovers out or clicks outside the leftnav
    # $('body > *').not('left-nav').on 'click', () =>
    #   console.log 'closing flyouts becuase the user clicked'
    #   @menusWithFlyouts().forEach (m) -> m.isSelected false

    # timer = undefined
    # $leftNav.hover () =>
    #   if(timer)
    #     window.clearTimeout timer
    # , () =>
    #   timer = window.setTimeout () =>
    #     console.log 'closing flyouts becuase the user move out for some time'
    #     @menusWithFlyouts().forEach (m) -> m.isSelected false
    #   , 1000
