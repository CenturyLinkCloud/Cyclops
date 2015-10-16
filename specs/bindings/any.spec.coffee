describe 'Bindings: any', ->
  beforeEach jasmine.prepareTestNode
  it 'is defined', ->
    expect(ko.bindingHandlers.any).toBeDefined()
    return
  it 'renders content when plain array has items', ->
    model = [ 1 ]
    spyOn console, 'log'
    testNode.innerHTML = '<div data-bind="any: $data">model has items</div>'
    ko.applyBindings model, testNode
    expect(testNode.innerHTML.indexOf('model has items')).toBeGreaterThan -1
    return
  it 'does not render content when plain array is empty', ->
    model = []
    spyOn console, 'log'
    testNode.innerHTML = '<div data-bind="any: $data">model has items</div>'
    ko.applyBindings model, testNode
    expect(testNode.innerHTML.indexOf('model has items')).toBe -1
    return
  it 'renders content when observable array has items', ->
    model = ko.observableArray([ 1 ])
    spyOn console, 'log'
    testNode.innerHTML = '<div data-bind="any: $data">model has items</div>'
    ko.applyBindings model, testNode
    expect(testNode.innerHTML.indexOf('model has items')).toBeGreaterThan -1
    return
  it 'does not render content when observable array is empty', ->
    model = ko.observableArray([])
    spyOn console, 'log'
    testNode.innerHTML = '<div data-bind="any: $data">model has items</div>'
    ko.applyBindings model, testNode
    expect(testNode.innerHTML.indexOf('model has items')).toBe -1
    return
  it 'can be applied to virtual elements', ->
    expect(ko.virtualElements.allowedBindings.any).toBeDefined()
    expect(ko.virtualElements.allowedBindings.any).toBeTruthy()
    return
  return
