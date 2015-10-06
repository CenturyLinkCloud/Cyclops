describe 'Helpers: TrackableObservable', ->
  it 'it hangs off the global knockout object', ->
    expect(ko.trackableObservable).toBeDefined()
    return
  it 'it defines commit, reset, commitedValue, and isTrackableObservable', ->
    t = ko.trackableObservable()
    expect(t.commit).toBeDefined()
    expect(t.reset).toBeDefined()
    expect(t.committedValue).toBeDefined()
    expect(t.isTrackableObservable).toBeDefined()
    return
  it 'claims to be a trackable observable', ->
    t = ko.trackableObservable()
    expect(t.isTrackableObservable).toBeTruthy()
    return
  it 'populates the initial value', ->
    t = ko.trackableObservable('init value')
    expect(t()).toEqual 'init value'
    return
  it 'reads uncommited value by default but initial value avalible', ->
    t = ko.trackableObservable('init value')
    t 'new value'
    expect(t()).toEqual 'new value'
    expect(t.committedValue()).toEqual 'init value'
    return
  it 'updates initial value when commit called', ->
    t = ko.trackableObservable('init value')
    t 'new value'
    t.commit()
    expect(t()).toEqual 'new value'
    expect(t.committedValue()).toEqual 'new value'
    return
  it 'reset after write reverts back to initial value', ->
    t = ko.trackableObservable('init value')
    t 'new value'
    t.reset()
    expect(t()).toEqual 'init value'
    return
  return
