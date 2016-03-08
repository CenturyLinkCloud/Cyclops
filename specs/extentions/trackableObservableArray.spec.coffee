describe 'Exentions: TrackableObservableArray', ->
  it 'it hangs off the global knockout object', ->
    expect(ko.trackableObservableArray).toBeDefined()
    return
  it 'it defines commit, reset, commitedValue, and isTrackableObservable', ->
    t = ko.trackableObservableArray()
    expect(t.commit).toBeDefined()
    expect(t.reset).toBeDefined()
    expect(t.committedValue).toBeDefined()
    expect(t.isTrackableObservableArray).toBeDefined()
    return
  it 'claims to be a trackable observable', ->
    t = ko.trackableObservableArray()
    expect(t.isTrackableObservableArray).toBeTruthy()
    return
  it 'returns commited value when reset called without a change', ->
    t = ko.trackableObservableArray()
    t([1,2,3])
    t.commit()
    t.reset()
    expect(t()).toEqual [1,2,3]
    return
  it 'populates the initial value', ->
    t = ko.trackableObservableArray([1,2,3])
    expect(t()).toEqual [1,2,3]
    return
  it 'reads uncommited value by default but initial value avalible', ->
    t = ko.trackableObservableArray([1,2,3])
    t [3,2,1]
    expect(t()).toEqual [3,2,1]
    expect(t.committedValue()).toEqual [1,2,3]
    return
  it 'updates initial value when commit called', ->
    t = ko.trackableObservableArray([1,2,3])
    t [3,2,1]
    t.commit()
    expect(t()).toEqual [3,2,1]
    expect(t.committedValue()).toEqual [3,2,1]
    return
  it 'reset after write reverts back to initial value', ->
    t = ko.trackableObservableArray([1,2,3])
    t [3,2,1]
    t.reset()
    expect(t()).toEqual [1,2,3]
    return
  return
