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


# - Title needs to wrap

class LeftNavViewModel
  constructor: (options, element) ->
    options = $.extend {}, options

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


    @close = () ->
      $(".flyout-menu").removeClass('open')
    @open = () ->
      $(".flyout-menu").toggleClass('open')
