# TODO: 1. disabled
$.fn.toggle = (options) ->
  options = $.extend {
    affirmativeText: "yes",
    negativeText: "no",
    defaultChecked: false
  }, options

  $(this).each (idx, input) ->
    $input = $(input)
    $container = $ "
      <div class=\"toggle\">
        <label>
          <div class=\"bug-fix\">
            <div class=\"text\">
              <div class=\"affirmative\">#{options.affirmativeText}</div>
              <div class=\"negative\">#{options.negativeText}</div>
            </div>
            <svg class=\"handle\" height=\"34\" viewBox=\"0 0 35 34\">
              <g>
                <rect x=\"13\" y=\"13\" fill=\"#777777\" width=\"1\" height=\"1\"/>
                <rect x=\"16\" y=\"13\" fill=\"#777777\" width=\"1\" height=\"1\"/>
                <rect x=\"19\" y=\"13\" fill=\"#777777\" width=\"1\" height=\"1\"/>
                <rect x=\"13\" y=\"16\" fill=\"#777777\" width=\"1\" height=\"1\"/>
                <rect x=\"16\" y=\"16\" fill=\"#777777\" width=\"1\" height=\"1\"/>
                <rect x=\"19\" y=\"16\" fill=\"#777777\" width=\"1\" height=\"1\"/>
                <rect x=\"13\" y=\"19\" fill=\"#777777\" width=\"1\" height=\"1\"/>
                <rect x=\"16\" y=\"19\" fill=\"#777777\" width=\"1\" height=\"1\"/>
                <rect x=\"19\" y=\"19\" fill=\"#777777\" width=\"1\" height=\"1\"/>
              </g>
            </svg>
          </div>
        </label>
      </div>
    "

    $container.insertBefore $input
    $input.insertBefore $container.find(".bug-fix")
    $input.prop 'checked', options.defaultChecked
    if options.onChange
      $input.change () ->
        options.onChange(this.checked)
