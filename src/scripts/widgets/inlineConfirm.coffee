$.fn.inlineConfirm = (options) ->
  options = $.extend {
    messageHtml: "Are you sure?"
    yesHtml: "YES"
    noHtml: "NO"
    timeout: 3000
  }, options

  $(this).each (idx, btn) ->
    $btn = $(btn)
    $container = $("<div class='inline-confirm'>" +
                      "<div class='viewport'>" +
                        "<div class='confirmation-container'>" +
                          "<span class='message'>Are you sure?</span>" +
                          "<button class='btn btn-default no'></button>" +
                          "<button class='yes'></button>" +
                        "</div>" +
                      "</div>" +
                    "</div>")
    $viewport = $container.find(".viewport")
    $confirmContainer = $container.find(".confirmation-container")
    $message = $container.find(".message")
    $yesBtn = $container.find(".yes")
    $noBtn = $container.find(".no")
    timeoutTracker = null

    # add all the right HTML
    $message.html options.messageHtml
    $yesBtn.html options.yesHtml
    $noBtn.html options.noHtml


    # copy styles
    float = $btn.css("float");
    $btn.attr("class").split(" ").forEach (c) ->
      if c.indexOf("btn") != 0
          $container.addClass(c);
          $btn.removeClass(c);
      else
        $yesBtn.addClass(c);

    $btn.css("float", float);
    $btn.addClass("original-button");
    $confirmContainer.css("float", float);

    # get the calculated height of the original and
    # figure out the amount to move it up to hide it

    # because the button maybe currently hidden lets
    # clone it and move it to the side (off the screen)
    # and show it to get the correct height to use.
    clone = $btn.clone()
                .css({'position': 'absolute', 'left': '-999999px'})
                .show()
                .attr({'aria-hidden': 'true'})
    clone.appendTo($("body"))
    buttonHeight = clone.innerHeight()
    clone.remove()
    topAmount = (buttonHeight * -1) + -5
    $container.height buttonHeight


    # insert the HTML and move the button inside
    $container.insertBefore $btn
    $btn.insertBefore $confirmContainer

    # helper function to do work
    reset = (event) ->
      if event
        event.preventDefault()
      $btn.animate({ opacity: 1 }, 100)
      $confirmContainer.animate({ opacity: 0 }, 200)
      $viewport.animate({ top: 0 }, 200)
      if timeoutTracker
        window.clearTimeout timeoutTracker

    show = (event) ->
      if event
        event.preventDefault()
      $btn.animate({ opacity: 0 }, 200)
      $confirmContainer.animate({ opacity: 1 }, 200)
      $viewport.animate({ top: topAmount }, 200)

    # wire up closing of the confirmation if they hover out too long.
    $confirmContainer.hover ->
        if timeoutTracker
            window.clearTimeout timeoutTracker
    , ->
        timeoutTracker = window.setTimeout reset, options.timeout

    # register all the click handlers from the original button
    _data = $._data($btn[0], "events")
    if _data
      _data.click.forEach (c) ->
        $yesBtn.on("click", c.handler)
        return

    # clean up the buttons when we are done...
    $yesBtn.on "click", reset

    # wire up the no button
    $noBtn.on "click", reset

    # remove those click handler from our the button
    $btn.off "click"

    # Wire up a new click event to show the confirm buttons
    $btn.on "click", (event) ->
      event.preventDefault()
      show()


    return
  return $(this)
