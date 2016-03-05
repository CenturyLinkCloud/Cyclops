if libraries.chartist
  $.fn.chart = (options) ->
    options = $.extend {
      type: 'Line'
      isLoading: false
      isErrored: false
      data: {}
      getLoadingMessageHtml: () -> return 'fetching data&hellip;'
      getEmptyMessageHtml: () -> return 'No data at this time.'
      getErrorMessageHtml: () -> return 'Unable to featch data.'
      chartOptions: {
        fullWidth: true,
        chartPadding: {
          right: 20
        },
        lineSmooth: false
      }
      responsiveOptions: {}
    }, options

    if(options.type == 'Donut')
      options.type = 'Pie'
      options.chartOptions.donut = true

    $(this).each (idx, element) ->
      $element = $(element)
      $element.addClass 'ct-chart'
      $messageContainer = $('<div class="message hide"></div>')
      $messageContainer.appendTo element

      chart = Chartist[options.type](
        element,
        ko.unwrap(options.data),
        options.chartOptions,
        options.responsiveOptions
      )

      _hidehideAndShowMessages = ko.computed () ->
          if ko.unwrap(options.isLoading)
            $messageContainer.show()
            $messageContainer.html options.getLoadingMessageHtml
          else if ko.unwrap(options.isErrored)
            $messageContainer.show()
            $messageContainer.html options.getErrorMessageHtml
          else
            d = ko.unwrap(options.data)
            if !d or !d.series or d.series.length < 1
              $messageContainer.show()
              $messageContainer.html options.getEmptyMessageHtml
            else
              $messageContainer.fadeOut()

      if ko.isObservable(options.data)
        options.data.subscribe (newValue) ->
          chart.update(newValue)


    return $(this)
