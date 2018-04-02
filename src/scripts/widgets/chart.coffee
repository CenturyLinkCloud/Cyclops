if libraries.chartist
  calculateTotal = (data) ->
    series = Chartist.getDataArray ko.unwrap(data)
    # assume one series
    return (series.reduce (prev, curr) -> prev + curr) * 2

  $.fn.chart = (options) ->
    options = $.extend {
      type: 'Line'
      isLoading: false
      isErrored: false
      data: {}
      getLoadingMessageHtml: () -> return 'fetching data&hellip;'
      getEmptyMessageHtml: () -> return 'No data at this time.'
      getErrorMessageHtml: () -> return 'Unable to fetch data.'
      chartOptions: {
        fullWidth: true,
        lineSmooth: false
      }
      responsiveOptions: {}
    }, options

    if options.type == 'Line' or options.type == 'Bar'
      unless options.chartOptions.chartPadding
        options.chartOptions.chartPadding = { right: 20 }

    if(options.type == 'Donut')
      options.type = 'Pie'
      options.chartOptions.donut = true
      options.chartOptions.donutWidth = '30%'

    isGuage = false
    if(options.type == 'Guage')
      isGuage = true
      options.type = 'Pie'
      options.chartOptions.donut = true
      options.chartOptions.donutWidth = '30%'
      options.chartOptions.startAngle= 270
      options.chartOptions.total = calculateTotal(options.data)


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
          if isGuage
            chart.update(newValue, {total: calculateTotal(newValue)}, true)
          else
            chart.update(newValue)


    return $(this)
