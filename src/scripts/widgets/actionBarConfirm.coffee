$.fn.actionToolbarConfirm = (options) ->
  options = $.extend {
    messageHtml: "Are you sure?"
    yesHtml: '<svg class="cyclops-icon"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#icon-check"></use></svg> yes'
    noHtml: '<svg class="cyclops-icon"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#icon-times"></use></svg> no'
    timeout: 3000
    easing: if libraries.jqueryUi then 'easeInOutQuad' else 'swing'
    classes: "action-toolbar-confirm-primary"
  }, options


  $(this).each (idx, action) ->
    $action = $(action)
    $confirm = $("<div class='action-toolbar-confirm #{options.classes}'>
                    <div class='buttons'>
                      <button class='yes'>#{options.yesHtml}</button><button class='no'>#{options.noHtml}</button>
                    </div>
                    <div class='message'>#{options.messageHtml}</div>
                  </div>")
    $confirm.hide()
    $yesBtn = $confirm.find('.yes')
    $noBtn = $confirm.find('.no')
    $area = $action.parents('.action-area')
    $actions = $area.find('.action-toolbar, .action-toolbar-left, .action-toolbar-right')
    timeoutTracker = null

    # add the confirmation to the DOM
    $area.append($confirm)

    #hide confirmation
    reset = (event) ->
      if event
        event.preventDefault()
      $actions.animate { 'margin-top': 0 }, {
        duration: 200
        easing: options.easing
        complete: () ->
          $area.removeClass("action-toolbar-confirm-shown")
          $confirm.hide()
      }
      return

    # show confirmation
    show = (event) ->
      if event
        event.preventDefault()
      $confirm.show()
      $area.addClass("action-toolbar-confirm-shown")
      $actions.animate { 'margin-top': -40 }, {
        duration: 200
        easing: options.easing
      }
      return

    # wire up closing of the confirmation if they hover out too long.
    $confirm.hover ->
        if timeoutTracker
            window.clearTimeout timeoutTracker
    , ->
        timeoutTracker = window.setTimeout reset, options.timeout

    # register all the click handlers from the original button
    events = $._data($action[0], "events")
    if(events)
      events.click.forEach (c) ->
        $yesBtn.on("click", c.handler)
        return

    # clean up the buttons when we are done...
    $yesBtn.on "click", reset

    # wire up the no button
    $noBtn.on "click", reset

    # remove those click handler from our the button
    $action.off "click"

    # Wire up a new click event to show the confirm buttons
    $action.on "click", show



    # show = () ->
    #   $confirm.show()
    #   $area.find(".action-toolbar, .action-toolbar-left, .action-toolbar-right").animate({
    #     "margin-top": -40
    #   })
