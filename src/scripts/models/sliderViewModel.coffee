# TODO: Support min values being the first step (i.e. when not 0, first step should be the min value)...

class SliderViewModel
  constructor: (options) ->
    # Defaults
    options = options || {}
    @minDefault = 1
    @maxDefault = 128
    @stepDefault = 1

    # Properties
    @hasjQueryUi = libraries.jqueryUi
    @value = ko.asObservable if options.value? then options.value else @minDefault
    @min = ko.asObservable if options.min? then options.min else @getMinFromValidationRule()
    @max = ko.asObservable if options.max? then options.max else @getMaxFromValidationRule()
    @step = ko.asObservable if options.step? then options.step else @stepDefault
    @disabled = ko.asObservable if options.disabled? then options.disabled else false
    # everything above here is needed if the simple textbox implementation aka jquery ui is not
    # loaded everything below is only needed if we are going to actually make a slider
    @value.subscribe (newValue) =>
      newValue = Math.floor(@convertToNumber(newValue, @min()))
      if @value() != newValue
        @value newValue
      @validateValue()
      @possibleValue @value()
      return
    @possibleValue = ko.observable @value()
    @shouldShowTicks = ko.asObservable if options.showTicks? then options.showTicks else true

    # Make sure the value is valid before going any further
    @validateValue()

    # Set up and validate bounds
    @minBound = ko.asObservable if options.minBound? then options.minBound else @min
    @maxBound = ko.asObservable if options.maxBound? then options.maxBound else @max
    @minBound.subscribe @validateValueAganistMinAndMaxBound
    @maxBound.subscribe @validateValueAganistMinAndMaxBound
    @validateValueAganistMinAndMaxBound()

    # Computed Properties
    @numberofTotalSteps = ko.pureComputed =>
      console.log("@numberofTotalSteps():", "#{@maxBound()} / #{@step()} = #{@maxBound() / @step()}")
      @maxBound() / @step()
      # PREVIOUSLY: @maxBound() - @minBound()

    @boundedSingleStepPercentage = ko.pureComputed =>
      console.log("@boundedSingleStepPercentage():", "100 / #{@numberofTotalSteps()} = #{100 / @numberofTotalSteps()}")
      100 / @numberofTotalSteps()

    @currentValuePercentage = ko.pureComputed =>
      console.log("@currentValuePercentage():", "#{@boundedSingleStepPercentage()} * #{@value()} = #{@boundedSingleStepPercentage() * (@value() / @step())}")
      @boundedSingleStepPercentage() * (@value() / @step())

    @validTrackLeftMargin = ko.pureComputed =>
      "#{Math.abs(@minBound() - @min()) * @boundedSingleStepPercentage()}%"

    @validTrackRightMargin = ko.pureComputed =>
      "#{Math.abs(@max() - @maxBound()) * @boundedSingleStepPercentage()}%"

    @canShowTicks = ko.pureComputed =>
      return if @numberofTotalSteps() > 32 then false else @shouldShowTicks()

    @fillRightValue = ko.pureComputed =>
      "#{100 - @getValuePercentage(@value())}%"

    @mainClasses = ko.pureComputed =>
      classes = []
      if @max() < @maxBound()
        classes.push 'has-max-bound'
      if @min() > @minBound()
        classes.push 'has-min-bound'
      if @disabled()
        classes.push 'disabled'
      classes.join ' '

    @isCommitedValueOutSideRange = ko.pureComputed =>
      if @value.isTrackableObservable
        return @value.committedValue() > @max() or @value.committedValue() < @min()
      false

    @outOfRangeMessage = ko.pureComputed =>
      if @value.isTrackableObservable && @isCommitedValueOutSideRange()
          return "The current value of <strong>#{@value.committedValue()}</strong> is outside
          the valid range of <strong>#{@min()} &ndash; #{@max()}</strong>. The closest allowable
          value has been selected."
      return

  validateValue: =>
    if @value() < @min()
      console.error 'value cannot be less than the minimum value.'
      @value @min()
    if @value() > @max()
      console.error 'value cannot be greater than the maximum value'
      @value @max()
    return

  validateValueAganistMinAndMaxBound: =>
   if @value() < @minBound()
     console.error 'value cannot be less than the min bound value.'
     @value @minBound()
   if @value() > @maxBound()
     console.error 'value cannot be greater than the max bound value'
     @value @maxBound()
   return

  getMinFromValidationRule: =>
    rules = if @value.rules then @value.rules().filter(((r) ->
      r.rule == 'min'
    )) else []
    minValue = if rules.length > 0 then rules[0].params else undefined
    if ko.isObservable(minValue)
      return minValue
    @convertToNumber minValue, @minDefault

  getMaxFromValidationRule: =>
    rules = if @value.rules then @value.rules().filter(((r) ->
      r.rule == 'max'
    )) else []
    maxValue = if rules.length > 0 then rules[0].params else undefined
    if ko.isObservable(maxValue)
      return maxValue
    @convertToNumber maxValue, @maxDefault

  getValuePercentage: (newValue) =>
    # TODO: Perhaps make currentValuePercentage use this function by passing the value in... Invert basically.
    console.log("@getValuePercentage(#{newValue}):", 100 / (@max() / @step()) * (newValue / @step()))
    # (newValue - @min()) * 100 / (@max() - @min())
    # # (newValue - @min()) * 100 / @step()
    # 100 / (@max() / @step()) * (newValue / @step())
    @currentValuePercentage()

  convertToNumber: (value, defaultValue) =>
    result = defaultValue
    if typeof value == 'string'
      result = parseFloat(value)
    else if !isNaN(parseFloat(value)) and isFinite(value)
      result = value
    result

  getOutOfRangeValueLeftPosition: =>
    "#{(@value.committedValue() - @minBound()) * 100 / (@maxBound() - @minBound())}%"
    # "#{(@value.committedValue() - @minBound()) * 100 / @step()}%"

  getCommitedValueStyles: =>
    console.log("@getCommitedValueStyles:", (@value.committedValue() - @minBound()) * 100 / (@maxBound() - @minBound()))
    leftPosition = (@value.committedValue() - @minBound()) * 100 / (@maxBound() - @minBound())
    # leftPosition = (@value.committedValue() - @minBound()) * 100 / @step()
    if leftPosition > 100
      return { display: 'none' }
    else
      return { display: 'block', left: "#{leftPosition}%" }

  getTickMarginPercentage: (index) =>
    console.log("getTickMarginPercentage(#{index()}): #{(index() + 1) * @boundedSingleStepPercentage()}%")
    "#{(index() + 1) * @boundedSingleStepPercentage()}%"

  getFillRightValue: =>
    console.log("@getFillRightValue():", "#{100 - @currentValuePercentage()}%")
    "#{100 - @currentValuePercentage()}%"

  # Events

  dragStartHandler: (event, ui) =>
    $(ui.helper).children('.slider-tooltip').fadeIn
      duration: 50
      easing: 'easeOutQuad'
    return

  dragStopHandler: (event, ui) =>
    $(ui.helper).children('.slider-tooltip').fadeOut
      duration: 200
      easing: 'easeOutQuad'
    $(ui.helper).css left: @currentValuePercentage() + '%'
    fill = $(ui.helper).siblings('.slider-value-fill')
    fill.css right: @getFillRightValue()
    @value @possibleValue()
    return

  dragHandler: (event, ui) =>
    track = $(ui.helper).parents('.slider-track')
    validTrack = $(ui.helper).parent('.slider-valid-track')
    fill = $(ui.helper).siblings('.slider-value-fill')
    stepWidth = track.width() / @numberofTotalSteps()
    fill.css right: validTrack.width() - (ui.position.left)
    console.log("Possible Value?", "Math.abs(Math.round(#{ui.position.left} / #{stepWidth})) = #{Math.abs(Math.round(ui.position.left / stepWidth)) * @step()}")
    @possibleValue (Math.abs(Math.round(ui.position.left / stepWidth)) * @step())
    return

  trackClick: (data, event) =>
    return if @disabled()
    element = $(event.target)
    if !element.is('.slider-handle2')
      track = element.parents('.slider-track')
      stepWidth = track.width() / @numberofTotalSteps()
      @possibleValue (Math.abs(Math.round(event.offsetX / stepWidth)) * @step())
      @value @possibleValue()
    return
