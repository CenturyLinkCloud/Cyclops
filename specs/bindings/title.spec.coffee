describe 'Bindings: title', ->
  beforeEach jasmine.prepareTestNode
  it 'adds title for just strings', ->
    model = title: 'the title'
    testNode.innerHTML = '<span data-bind="title: title"></span>'
    ko.applyBindings model, testNode
    expect(testNode.childNodes[0].getAttribute('title')).toEqual 'the title'
    return
  it 'adds href for observables and changes with observed values', ->
    model = title: ko.observable('the title')
    testNode.innerHTML = '<span data-bind="title: title"></span>'
    ko.applyBindings model, testNode
    expect(testNode.childNodes[0].getAttribute('title')).toEqual 'the title'
    model.title 'new title'
    expect(testNode.childNodes[0].getAttribute('title')).toEqual 'new title'
    return
  return
