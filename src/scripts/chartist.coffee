if libraries.chartist
  Chartist.plugins = Chartist.plugins || {};

  Chartist.plugins.cyclops = (options) ->
    defaultOptions = {
      getLoadingMessageHtml: () -> return 'fetching data&hellip;'
      getEmptyMessageHtml: () -> return 'No data at this time.'
      getErrorMessageHtml: () -> return 'Unable to featch data.'
      isLoading: false
      isErrored: false
    }
    options = $.extend(defaultOptions, options);
    messageContainer = $('<div class="message hide"></div>')

    hideAndShowMessages = (isLoading, isErrored, chart) ->
      if isLoading
        messageContainer.show()
        messageContainer.html options.getLoadingMessageHtml
      else if isErrored
        messageContainer.show()
        messageContainer.html options.getErrorMessageHtml
      else
        d = ko.unwrap(chart.data)
        if !d or !d.series or d.series.length < 1
          messageContainer.show()
          messageContainer.html options.getEmptyMessageHtml
        else
          messageContainer.fadeOut()

    return (chart) ->
      messageContainer.appendTo chart.container
      hideAndShowMessages(ko.unwrap(options.isLoading), ko.unwrap(options.isErrored), chart)
      if ko.isObservable(options.isLoading)
        options.isLoading.subscribe (newValue) ->
          hideAndShowMessages(newValue, ko.unwrap(options.isErrored), chart)

      if ko.isObservable(options.isErrored)
        options.isErrored.subscribe (newValue) ->
          hideAndShowMessages(ko.unwrap(options.isLoading), newValue, chart)

      chart.on 'data', (chartOptions) =>
        if chartOptions.type == 'initial'
          if ko.isObservable(chartOptions.data)
            chartOptions.data.subscribe (newData) ->
              chart.update(newData)
            chartOptions.data = ko.unwrap chartOptions.data
            chart.update(chartOptions.data)
