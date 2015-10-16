describe 'Bindings: href', ->
  beforeEach jasmine.prepareTestNode
  it 'adds href for just strings', ->
    model = url: 'osbornm.com'
    testNode.innerHTML = '<a data-bind="href: url"></a>'
    ko.applyBindings model, testNode
    expect(testNode.childNodes[0].getAttribute('href')).toEqual 'osbornm.com'
    return
  it 'adds href for observables and changes with observed values', ->
    model = url: ko.observable('osbornm.com')
    testNode.innerHTML = '<a data-bind="href: url"></a>'
    ko.applyBindings model, testNode
    expect(testNode.childNodes[0].getAttribute('href')).toEqual 'osbornm.com'
    model.url 'github.com/osbornm/uppercut'
    expect(testNode.childNodes[0].getAttribute('href')).toEqual 'github.com/osbornm/uppercut'
    return
  return
