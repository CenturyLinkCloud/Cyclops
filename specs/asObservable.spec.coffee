describe 'AsObservable', ->
  it 'it hangs off the global knockout object', ->
    expect(ko.asObservable).toBeDefined()
    return
  it 'returns an observable from a value', ->
    result = ko.asObservable(5)
    expect(ko.isObservable(result)).toBeTruthy()
    return
  it 'returns the same observable from an observable', ->
    init = ko.observable(4)
    result = ko.asObservable(init)
    expect(result).toEqual init
    return
  return
describe 'AsObservableArray', ->
  it 'it hangs off the global knockout object', ->
    expect(ko.asObservableArray).toBeDefined()
    return
  it 'returns an observable from a value', ->
    result = ko.asObservableArray([])
    expect(ko.isObservable(result)).toBeTruthy()
    return
  it 'returns the same observable from an observable', ->
    init = ko.observableArray([ 1 ])
    result = ko.asObservableArray(init)
    expect(result).toEqual init
    return
  return
