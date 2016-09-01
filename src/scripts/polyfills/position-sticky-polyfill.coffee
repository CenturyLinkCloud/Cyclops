#
# Polyfill for Sticky Positioning (i.e. `position: sticky`)
#
# Based on the demo from Polyfill.js, but extended to support scrolling of
# sticky content when its height exceeds that of the viewport.
#
(($) ->

  uniqueID = 0

  onScroll = (element) ->
    return unless data = element.data('position:sticky')

    # Relatively Position Parent
    parent = element.parent()
    unless parent.css('position') == 'absolute' or parent.css('position') == 'relative'
      parent.css('position', 'relative')

    # Get the Offset Parent (should be parent)
    offsetParent = element.offsetParent()

    # Pin to Bottom
    if ($ window).scrollTop() >= (offsetParent.offset().top + (offsetParent.outerHeight() - element.outerHeight(true)))
      if !data.clone
        data.clone = element.clone()
          .css
            position: 'absolute'
            top: 'auto'
            bottom: 0
            left: 'auto'
          .insertBefore(element)
        element.css('visibility', 'hidden')
        onResize(element)
      else
        data.clone.css
          position: 'absolute'
          top: 'auto'
          bottom: 0
          left: 'auto'

    # Pin to Top
    else if ($ window).scrollTop() >= (data.offsetTop - data.top)
      if !data.clone
        data.clone = element.clone()
          .css
            position: 'fixed'
            top: data.top
            bottom: 'auto'
            left: 'auto'
          .insertBefore(element)
        element.css('visibility', 'hidden')
      else
        data.clone.css
          position: 'fixed'
          top: data.top
          bottom: 'auto'
          left: 'auto'
      onResize(element)

    # Remove Clone
    else
      if data.clone
        data.clone.remove()
        data.clone = null
        element.css('visibility', 'visible')

  onResize = (element) ->
    data = element.data('position:sticky')
    offset = undefined
    # Make sure no operations that require a repaint are
    # done unless a cloned element exists
    if data and data.clone
      offset = element.offset()
      data.offsetTop = offset.top
      data.clone.css
        left: offset.left
        width: element.outerWidth()

  doMatched = (rules) ->
    rules.each (rule) ->
      elements = ($ rule.getSelectors())
      declaration = rule.getDeclaration()
      elements.each (idx, element) ->
        element = ($ element)
        data = element.data('position:sticky')
        if !data
          data =
            id: ++uniqueID
            offsetTop: element.offset().top
            top: parseInt(declaration.top, 10)
          element.data('position:sticky', data)
        onScroll(element)
        ($ window).on("scroll.position:sticky:#{data.id}", -> onScroll(element))
        ($ window).on("resize.position:sticky:#{data.id}", -> onResize(element))

  undoUnmatched = (rules) ->
    rules.each (rule) ->
      elements = ($ rule.getSelectors())
      elements.each (idx, element) ->
        element = ($ element)
        data = element.data('position:sticky')
        if data
          if data.clone
            data.clone.remove()
            element.css('visibility', 'visible')
          ($ window).off(".position:sticky:#{data.id}")
          element.removeData('position:sticky')

  #
  # Check to see if the browser supports sticky positioning natively or not. If
  # it does, we'll just skip the polyfill altogether.
  #
  isSupportedNatively = () ->
    testElement = ($ '<test-element>')
    for prefix in [ '', '-webkit-', '-moz-', '-ms-' ]
      testElement.css('position', "#{prefix}sticky")
      return true if testElement.css('position').indexOf('sticky') != -1
    false

  #
  # Bail out if supported natively.
  #
  return if isSupportedNatively()

  #
  # Register the polyfill with Polyfill.js.
  #
  Polyfill({ declarations: [ 'position:sticky' ] }, include: [ 'position-sticky' ])
    .doMatched(doMatched)
    .undoUnmatched(undoUnmatched)

) jQuery
