describe 'Bindings: slide', ->
  beforeEach jasmine.prepareTestNode

  it 'is defined', ->
    expect(ko.bindingHandlers.slide).toBeDefined()

  it 'throws error when passing object with no visible property', ->
    testNode.innerHTML = '<div data-bind="slide: $data"></div>'
    expect(() -> ko.applyBindings {}, testNode).toThrow()
