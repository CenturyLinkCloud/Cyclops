describe 'helpers: isDeferred', ->
  it 'it hangs off the internal helpers object', ->
    expect(helpers.isDeferred).toBeDefined()
    return
  it 'returns true for jquery Deferred object', ->
    def = $.Deferred()
    result = helpers.isDeferred def
    expect(result).toBeTruthy()
    return
  it 'returns false for null obejct', ->
    result = helpers.isDeferred null
    expect(result).toBeFalsy()
    return
  it 'returns false for observable obejct', ->
    result = helpers.isDeferred ko.observable('password')
    expect(result).toBeFalsy()
    return
