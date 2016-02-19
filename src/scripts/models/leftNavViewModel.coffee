# var menus = new leftNav();

# <left-nav params="menus: menus, selectedMenu: 'manage', "></left-nav>
#
#  var menu = $.ajax(...).complete(function(data) { menus.loadFrom(data); }
#      i dfs;ljkg;sdfg
#  var myMenu = menu.find(manage)
#

# TODO
# - fix fade in out animations
# - style buttons (active/focus states etc)
# - may need to look at window resize and recalc scroll buttons
# - scrolling on iphone is fucked up
# - size for the expanded leftnav view
# - icons not aligned in menu
# - container widths need to be adjusted at each media viewport
# - observable for selectedItem

# - menus with empty items and no href (filter them out)
# - overflow on flyout

class LeftNavFlyoutItem
  constructor: (options) ->
    options = $.extend {
        name: 'unknown'
        description: 'unknown item'
        href: '#'
        isNew: false
        isBeta: false
    }, options

    @isNew = ko.asObservable(options.isNew)
    @isBeta = ko.asObservable(options.isBeta)
    @hasBadge = ko.pureComputed () =>
      return @isNew() || @isBeta()
    @badgeText = ko.pureComputed () =>
      if @isBeta()
        return 'beta'
      if @isNew()
        return 'new'
    @name = ko.asObservable(options.name)
    @description = ko.asObservable(options.description)
    @href = ko.asObservable(options.href)


class LeftNavMenuItem
  toggleFlyout: (item) ->
    item.isSelected !item.isSelected()

  constructor: (options) ->
    options = $.extend {
        iconId: '#icon-circle-o'
        name: 'unknown'
        items: []
    }, options

    @name = ko.asObservable(options.name)
    @icon = ko.asObservable(options.iconId)
    @href = ko.asObservable(options.href)
    @isSelected = ko.observable(false);
    @rawFlayoutItems = ko.asObservableArray(options.items)
    @flayoutItems = ko.pureComputed () =>
      return @rawFlayoutItems().map (f) -> return new LeftNavFlyoutItem(f)
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
      return @rawMenus().map (m) -> return new LeftNavMenuItem(m)
    @menusWithFlyouts = ko.pureComputed () =>
      return @menus().filter (m) -> m.flayoutItems().length > 0

    @selectFlyout = (menu) =>
      previousState = menu.isSelected()
      @menusWithFlyouts().forEach (m) -> m.isSelected false
      if(!previousState)
        menu.isSelected !previousState


    # Auto Close any Flyouts when the user hovers out or clicks outside the leftnav
    # $('body > *').not('left-nav').on 'click', () =>
    #   console.log 'closing flyouts becuase the user clicked'
    #   @menusWithFlyouts().forEach (m) -> m.isSelected false

    timer = undefined
    $leftNav.hover () =>
      if(timer)
        window.clearTimeout timer
    , () =>
      timer = window.setTimeout () =>
        console.log 'closing flyouts becuase the user move out for some time'
        @menusWithFlyouts().forEach (m) -> m.isSelected false
      , 1000


    #temp crap
    @close = () ->
      $(".flyout-menu").removeClass('open')
    @open = () ->
      $(".flyout-menu").toggleClass('open')
