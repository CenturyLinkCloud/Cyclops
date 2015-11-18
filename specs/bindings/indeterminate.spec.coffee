describe 'Bindings: indeterminate', ->
  beforeEach jasmine.prepareTestNode
  it 'adds indeterminate when true', ->
    model = indeterminate: true
    testNode.innerHTML = '<input type="checkbox" data-bind="indeterminate: indeterminate" />'
    ko.applyBindings model, testNode
    expect(testNode.childNodes[0].indeterminate).toEqual true
    return
  it 'doe not add indeterminate when false', ->
    model = indeterminate: false
    testNode.innerHTML = '<input type="checkbox" data-bind="indeterminate: indeterminate" />'
    ko.applyBindings model, testNode
    expect(testNode.childNodes[0].indeterminate).toEqual false
    return
  it 'doe not add indeterminate when undefined', ->
    model = indeterminate: undefined
    testNode.innerHTML = '<input type="checkbox" data-bind="indeterminate: indeterminate" />'
    ko.applyBindings model, testNode
    expect(testNode.childNodes[0].indeterminate).toEqual false
    return
  return
