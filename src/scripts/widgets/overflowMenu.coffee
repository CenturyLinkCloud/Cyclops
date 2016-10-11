flexObjects = []
resizeTimeout = undefined
# When the page is resized, adjust the overflowMenus.

adjustoverflowMenu = ->
  $(flexObjects).each ->
    $(this).overflowMenu('undo': true).overflowMenu @options
    return
  return

# only wire this up if we have one...
$(window).resize ->
  window.clearTimeout resizeTimeout
  resizeTimeout = window.setTimeout((->
    adjustoverflowMenu()
    return
  ), 200)
  return

$.fn.overflowMenu = (options) ->
  checkFlexObject = undefined
  s = $.extend({
    'threshold': 2
    'cutoff': 0
    'linkText': 'more&hellip;'
    'linkTitle': 'View More'
    'linkTextAll': 'actions&hellip;'
    'linkTitleAll': 'Open/Close Menu'
    'undo': false
  }, options)
  @options = s
  # Set options on object
  checkFlexObject = $.inArray(this, flexObjects)
  # Checks if this object is already in the flexObjects array
  if checkFlexObject >= 0
    flexObjects.splice checkFlexObject, 1
    # Remove this object if found
  else
    flexObjects.push this
    # Add this object to the flexObjects array
  @each ->
    $this = $(this)
    $items = $this.find('> li')
    $firstItem = $items.first()
    $lastItem = $items.last()
    $rightToolbar = $this.siblings '.action-toolbar-right, .navbar-local-right'
    numItems = $this.find('li').length
    firstItemTop = Math.floor(($firstItem.offset() or {}).top)
    firstItemHeight = Math.floor($firstItem.outerHeight(true))
    $lastChild = undefined
    keepLooking = undefined
    $moreItem = undefined
    numToRemove = undefined
    allInPopup = false
    $menu = undefined
    i = undefined

    if $rightToolbar
      # add an additio 10 px to adjust for non fixed width fonts
      newWidth = $this.parent().width() - $rightToolbar.width() - 10
      $this.css 'margin-right', 0
      $this.css 'width', newWidth

    needsMenu = ($itemOfInterest) ->
      if $itemOfInterest.length < 1
        return false
      result = if Math.ceil($itemOfInterest.offset().top) >= firstItemTop + firstItemHeight then true else false
      # Values may be calculated from em and give us something other than round numbers. Browsers may round these inconsistently. So, let's round numbers to make it easier to trigger overflowMenu.
      result

    if needsMenu($lastItem) and numItems > s.threshold and !s.undo and $this.is(':visible')
      $popup = $('<ul class="dropdown-menu"></ul>')
      i = numItems
      while i > 1
        # Find all of the list items that have been pushed below the first item. Put those items into the popup menu. Put one additional item into the popup menu to cover situations where the last item is shorter than the "more" text.
        $lastChild = $this.find('> li:last-child')
        keepLooking = needsMenu($lastChild)
        $lastChild.appendTo $popup
        # If there only a few items left in the navigation bar, move them all to the popup menu.
        if i - 1 <= s.cutoff
          # We've removed the ith item, so i - 1 gives us the number of items remaining.
          $($this.children().get().reverse()).appendTo $popup
          allInPopup = true
          break
        if !keepLooking
          break
        i--
      if allInPopup
        button = $("<a role='button' href='#' title='#{s.linkTitleAll}'>#{s.linkTextAll} <svg class='cyclops-icon'><use xlink:href='#icon-caret-down'></svg></a>")
      else
        button = $("<a role='button' href='#' title='#{s.linkTitle}'>#{s.linkText} <svg class='cyclops-icon'><use xlink:href='#icon-caret-down'></svg></a>")

      button.dropdown()
      li = $('<li class="dropdown overflow-menu"></li>')
      li.append(button)
      $this.append li
      $moreItem = $this.find('> li.overflow-menu')
      # Check to see whether the more link has been pushed down. This might happen if the link immediately before it is especially wide.
      if needsMenu($moreItem)
        $this.find('> li:nth-last-child(2)').appendTo $popup
      # Our popup menu is currently in reverse order. Let's fix that.
      $popup.children().each (i, li) ->
        $popup.prepend li
        return
      $moreItem.append $popup
    else if s.undo and $this.find('ul.dropdown-menu')
      $menu = $this.find('ul.dropdown-menu')
      numToRemove = $menu.find('li').length
      i = 1
      while i <= numToRemove
        $menu.find('> li:first-child').appendTo $this
        i++
      $menu.remove()
      $this.find('> li.dropdown').remove()
    return
