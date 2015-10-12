describe 'Validators: checked', ->
  it 'it hangs off the global rules object', ->
    expect(ko.validation.rules.checked).toBeDefined()
    return
  it 'returns true for truthy value', ->
    expect(ko.validation.rules.checked.validator true ).toBeTruthy()
    expect(ko.validation.rules.checked.validator 1 ).toBeTruthy()
    expect(ko.validation.rules.checked.validator 'a' ).toBeTruthy()
    value = ko.observable(true)
    expect(ko.validation.rules.checked.validator value ).toBeTruthy()
    return
  it 'returns false for falsy value', ->
    expect(ko.validation.rules.checked.validator false ).toBeFalsy()
    expect(ko.validation.rules.checked.validator 0 ).toBeFalsy()
    expect(ko.validation.rules.checked.validator '' ).toBeFalsy()
    value = ko.observable(false)
    expect(ko.validation.rules.checked.validator value ).toBeFalsy()
    return
  return
