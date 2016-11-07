# TODO: 1. disabled

#
# Cyclops Toggle Widget
#
# Usage:
#
#   TODO
#
$.widget "cylops.toggle",

  options:
    affirmativeText: "yes"
    negativeText: "no"
    defaultChecked: false

  containerTemplate: (context) ->
    """
    <div class="toggle">
      <label>
        <div class="bug-fix">
          <div class="text">
            <div class="affirmative">#{context.affirmativeText}</div>
            <div class="negative">#{context.negativeText}</div>
          </div>
          <svg class="handle" height="34" viewBox="0 0 35 34">
            <g>
              <rect x="13" y="13" fill="#777777" width="1" height="1"/>
              <rect x="16" y="13" fill="#777777" width="1" height="1"/>
              <rect x="19" y="13" fill="#777777" width="1" height="1"/>
              <rect x="13" y="16" fill="#777777" width="1" height="1"/>
              <rect x="16" y="16" fill="#777777" width="1" height="1"/>
              <rect x="19" y="16" fill="#777777" width="1" height="1"/>
              <rect x="13" y="19" fill="#777777" width="1" height="1"/>
              <rect x="16" y="19" fill="#777777" width="1" height="1"/>
              <rect x="19" y="19" fill="#777777" width="1" height="1"/>
            </g>
          </svg>
        </div>
      </label>
    </div>
    """

  _create: ->
    $container = ($ this.containerTemplate
      affirmativeText: this.options.affirmativeText
      negativeText: this.options.negativeText
    )

    $container.insertBefore this.element
    this.element.insertBefore $container.find(".bug-fix")
    this.element.prop "checked", this.options.defaultChecked
    if this.options.onChange
      this.element.on "change", (event) =>
        this.options.onChange(this.element.checked)

  _destroy: ->
    this.element.off "change"
    # TODO: Remove the container from the DOM
