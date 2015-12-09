helpers.isDeferred = (data) ->
  if data != null && typeof data.then == 'function'
    return true
  else
    return false
