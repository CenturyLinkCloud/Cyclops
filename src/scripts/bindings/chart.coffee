if libraries.chartist
  ko.bindingHandlers.chart =
    init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
       $element = $(element)
       options = $.extend {
         isLoading: false
         isErrored: false
         type: 'Line'
       }, valueAccessor()
       $element.addClass 'ct-chart'

       chartOptions = {
         # fullWidth: true, need to move labesl to middle then
         plugins: [
           Chartist.plugins.cyclops({
             isLoading: options.isLoading,
             isErrored: options.isErrored
           })
         ]
       }

       if(options.type == 'Donut')
         options.type = 'Pie'
         chartOptions.donut = true


       Chartist[options.type](
        element,
        options.data,
        chartOptions
       )
       return
