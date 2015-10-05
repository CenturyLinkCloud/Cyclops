###
# An observable that tracks an edits
# @param initValues The initial array of the observable
###

ko.trackableObservableArray = (initValues) ->
  initArray = ko.unwrap(initValues) or []
  oldValues = initArray.slice()
  result = ko.observableArray(initValues)

  ###
  # The previous array that has been marked as `initial` or `committed`
  ###

  result.committedValue = ko.observableArray(initArray.slice())

  ###
  # Commit the current array as the new commited array.
  # e.g. when your save completes and you want to reset to this array.
  # @function
  ###

  result.commit = ->
    result.committedValue result()
    return

  ###
  # Reset the current array to the initial array
  # @function
  ###

  result.reset = ->
    $.each oldValues, ->
      if @reset
        @reset()
      return
    result oldValues.slice()
    if result.isModified
      result.isModified false
    return

  result.isTrackableObservableArray = true
  result
