describe 'Bindings: console', ->
  beforeEach jasmine.prepareTestNode
  it 'calls console with plain text', ->
    model = name: 'uppercut'
    spyOn console, 'log'
    testNode.innerHTML = '<div data-bind="console: name"></div>'
    ko.applyBindings model, testNode
    expect(console.log.calls.count()).toEqual 1
    expect(console.log.calls.argsFor(0)).toEqual [ 'uppercut' ]
    return
  it 'calls console with object', ->
    model = name: 'uppercut'
    spyOn console, 'log'
    testNode.innerHTML = '<div data-bind="console: $data"></div>'
    ko.applyBindings model, testNode
    expect(console.log.calls.count()).toEqual 1
    expect(console.log.calls.argsFor(0)).toEqual [ model ]
    return
  it 'calls console each time observabel updated', ->
    model = name: ko.observable('uppercut')
    spyOn console, 'log'
    testNode.innerHTML = '<div data-bind="console: name"></div>'
    ko.applyBindings model, testNode
    model.name 'uppercut2'
    expect(console.log.calls.count()).toEqual 2
    expect(console.log.calls.argsFor(0)).toEqual [ 'uppercut' ]
    expect(console.log.calls.argsFor(1)).toEqual [ 'uppercut2' ]
    return
  return
