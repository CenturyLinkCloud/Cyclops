Chart.defaults.global = {
    # Boolean - Whether to animate the chart
    animation: true,

    # Number - Number of animation steps
    animationSteps: 60,

    # String - Animation easing effect
    # Possible effects are:
    # [easeInOutQuart, linear, easeOutBounce, easeInBack, easeInOutQuad,
    #  easeOutQuart, easeOutQuad, easeInOutBounce, easeOutSine, easeInOutCubic,
    #  easeInExpo, easeInOutBack, easeInCirc, easeInOutElastic, easeOutBack,
    #  easeInQuad, easeInOutExpo, easeInQuart, easeOutQuint, easeInOutCirc,
    #  easeInSine, easeOutExpo, easeOutCirc, easeOutCubic, easeInQuint,
    #  easeInElastic, easeInOutSine, easeInOutQuint, easeInBounce,
    #  easeOutElastic, easeInCubic]
    animationEasing: "easeOutQuart",

    # Boolean - If we should show the scale at all
    showScale: true,

    # Boolean - If we want to override with a hard coded scale
    scaleOverride: false,

    # ** Required if scaleOverride is true **
    # Number - The number of steps in a hard coded scale
    scaleSteps: null,
    # Number - The value jump in the hard coded scale
    scaleStepWidth: null,
    # Number - The scale starting value
    scaleStartValue: null,

    # String - Colour of the scale line
    scaleLineColor: "rgba(0,0,0,.1)",

    # Number - Pixel width of the scale line
    scaleLineWidth: 1,

    # Boolean - Whether to show labels on the scale
    scaleShowLabels: true,

    # Interpolated JS string - can access value
    scaleLabel: "<%=value%>",

    # Boolean - Whether the scale should stick to integers, not floats even if drawing space is there
    scaleIntegersOnly: true,

    # Boolean - Whether the scale should start at zero, or an order of magnitude down from the lowest value
    scaleBeginAtZero: false,

    # String - Scale label font declaration for the scale label
    scaleFontFamily: "'Open Sans', Helvetica, Arial, Sans-Serif",

    # Number - Scale label font size in pixels
    scaleFontSize: 12,

    # String - Scale label font weight style
    scaleFontStyle: "normal",

    # String - Scale label font colour
    scaleFontColor: "#666",

    # Boolean - whether or not the chart should be responsive and resize when the browser does.
    responsive: true,

    # Boolean - whether to maintain the starting aspect ratio or not when responsive, if set to false, will take up entire container
    maintainAspectRatio: true,

    # Boolean - Determines whether to draw tooltips on the canvas or not
    showTooltips: true,

    # Function - Determines whether to execute the customTooltips function instead of drawing the built in tooltips (See [Advanced - External Tooltips](#advanced-usage-custom-tooltips))
    customTooltips: false,

    # Array - Array of string names to attach tooltip events
    tooltipEvents: ["mousemove", "touchstart", "touchmove"],

    # String - Tooltip background colour
    tooltipFillColor: "rgba(0,0,0,0.8)",

    # String - Tooltip label font declaration for the scale label
    tooltipFontFamily: "'Open Sans', Helvetica, Arial, Sans-Serif",

    # Number - Tooltip label font size in pixels
    tooltipFontSize: 12,

    # String - Tooltip font weight style
    tooltipFontStyle: "normal",

    # String - Tooltip label font colour
    tooltipFontColor: "#fff",

    # String - Tooltip title font declaration for the scale label
    tooltipTitleFontFamily: "'Open Sans', Helvetica, Arial, Sans-Serif",

    # Number - Tooltip title font size in pixels
    tooltipTitleFontSize: 14,

    # String - Tooltip title font weight style
    tooltipTitleFontStyle: "bold",

    # String - Tooltip title font colour
    tooltipTitleFontColor: "#fff",

    # Number - pixel width of padding around tooltip text
    tooltipYPadding: 6,

    # Number - pixel width of padding around tooltip text
    tooltipXPadding: 6,

    # Number - Size of the caret on the tooltip
    tooltipCaretSize: 8,

    # Number - Pixel radius of the tooltip border
    tooltipCornerRadius: 3,

    # Number - Pixel offset from point x to tooltip edge
    tooltipXOffset: 10,

    # String - Template string for single tooltips
    tooltipTemplate: "<%if (label){%><%=label%>: <%}%><%= value %>",

    # String - Template string for multiple tooltips
    multiTooltipTemplate: "<%= datasetLabel %> - <%= value %>",

    # Function - Will fire on animation progression.
    onAnimationProgress: (args) ->
      # body...

    ,

    # Function - Will fire on animation completion.
    onAnimationComplete: (args) ->
      # body...


}

Chart.defaults.Line = {

    # Boolean - Whether grid lines are shown across the chart
    scaleShowGridLines : true,

    # String - Colour of the grid lines
    scaleGridLineColor : "rgba(0,0,0,.05)",

    # Number - Width of the grid lines
    scaleGridLineWidth : 1,

    # Boolean - Whether to show horizontal lines (except X axis)
    scaleShowHorizontalLines: false,

    # Boolean - Whether to show vertical lines (except Y axis)
    scaleShowVerticalLines: false,

    # Boolean - If we want to override with a hard coded scale
    scaleOverride: true,

    # ** Required if scaleOverride is true **
    # Number - The number of steps in a hard coded scale
    scaleSteps: 5,
    # Number - The value jump in the hard coded scale
    scaleStepWidth: 20,
    # Number - The scale starting value
    scaleStartValue: 0,

    # Boolean - Whether the line is curved between points
    bezierCurve : true,

    # Number - Tension of the bezier curve between points
    bezierCurveTension : 0.2,

    # Boolean - Whether to show a dot for each point
    pointDot : true,

    # Number - Radius of each point dot in pixels
    pointDotRadius : 4,

    # Number - Pixel width of point dot stroke
    pointDotStrokeWidth : 1,

    # Number - amount extra to add to the radius to cater for hit detection outside the drawn point
    pointHitDetectionRadius : 20,

    # Boolean - Whether to show a stroke for datasets
    datasetStroke : true,

    # Number - Pixel width of dataset stroke
    datasetStrokeWidth : 2,

    # Boolean - Whether to fill the dataset with a colour
    datasetFill : true,

    # String - A legend template
    legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].strokeColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"

}

Chart.defaults.Bar = {
    # Boolean - Whether the scale should start at zero, or an order of magnitude down from the lowest value
    scaleBeginAtZero : true,

    # Boolean - Whether grid lines are shown across the chart
    scaleShowGridLines : true,

    # String - Colour of the grid lines
    scaleGridLineColor : "rgba(0,0,0,.05)",

    # Number - Width of the grid lines
    scaleGridLineWidth : 1,

    # Boolean - Whether to show horizontal lines (except X axis)
    scaleShowHorizontalLines: false,

    # Boolean - Whether to show vertical lines (except Y axis)
    scaleShowVerticalLines: false,

    # Boolean - If there is a stroke on each bar
    barShowStroke : true,

    # Number - Pixel width of the bar stroke
    barStrokeWidth : 2,

    # Number - Spacing between each of the X value sets
    barValueSpacing : 5,

    # Number - Spacing between data sets within X values
    barDatasetSpacing : 1,

    # String - A legend template
    legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].fillColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"

}

Chart.defaults.Doughnut = {
    # Boolean - Whether we should show a stroke on each segment
    segmentShowStroke : true,

    # String - The colour of each segment stroke
    segmentStrokeColor : "#fff",

    # Number - The width of each segment stroke
    segmentStrokeWidth : 2,

    # Number - The percentage of the chart that we cut out of the middle
    percentageInnerCutout : 50, #  This is 0 for Pie charts

    # Number - Amount of animation steps
    animationSteps : 100,

    # String - Animation easing effect
    animationEasing : "easeOutBounce",

    # Boolean - Whether we animate the rotation of the Doughnut
    animateRotate : true,

    # Boolean - Whether we animate scaling the Doughnut from the centre
    animateScale : false,

    # String - A legend template
    legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>"

}

Chart.defaults.Pie = {
    # Boolean - Whether we should show a stroke on each segment
    segmentShowStroke : true,

    # String - The colour of each segment stroke
    segmentStrokeColor : "#fff",

    # Number - The width of each segment stroke
    segmentStrokeWidth : 2,

    # Number - The percentage of the chart that we cut out of the middle
    percentageInnerCutout : 0, #  This is 0 for Pie charts

    # Number - Amount of animation steps
    animationSteps : 100,

    # String - Animation easing effect
    animationEasing : "easeOutBounce",

    # Boolean - Whether we animate the rotation of the Doughnut
    animateRotate : true,

    # Boolean - Whether we animate scaling the Doughnut from the centre
    animateScale : false,

    # String - A legend template
    legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<segments.length; i++){%><li><span style=\"background-color:<%=segments[i].fillColor%>\"></span><%if(segments[i].label){%><%=segments[i].label%><%}%></li><%}%></ul>"

}
