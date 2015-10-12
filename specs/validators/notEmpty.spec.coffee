describe 'Validators: notEmpty', ->
  it 'it hangs off the global rules object', ->
    expect(ko.validation.rules.notEmpty).toBeDefined()
    return

  it 'returns true for array with items', ->
    expect(ko.validation.rules.notEmpty.validator [1,2,3] ).toBeTruthy()
    return
  it 'returns true for object with truthy length property', ->
    expect(ko.validation.rules.notEmpty.validator {length: 1} ).toBeTruthy()
    return
  it 'returns true for observable array that is not empty', ->
    value = ko.observableArray [1]
    expect(ko.validation.rules.notEmpty.validator value ).toBeTruthy()
    return
  it 'returns true for array with items', ->
    expect(ko.validation.rules.notEmpty.validator [] ).toBeFalsy()
    return
  it 'returns true for object with truthy length property', ->
    expect(ko.validation.rules.notEmpty.validator {length: 0} ).toBeFalsy()
    return
  it 'returns true for observable array that is not empty', ->
    value = ko.observableArray []
    expect(ko.validation.rules.notEmpty.validator value ).toBeFalsy()
    return
  return
