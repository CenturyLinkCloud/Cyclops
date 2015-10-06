describe 'Bindings: fadeSlide', ->
  beforeEach jasmine.prepareTestNode

  it 'is defined', ->
    expect(ko.bindingHandlers.fadeSlide).toBeDefined()

  it 'throws error when passing object with no visible property', ->
    testNode.innerHTML = '<div data-bind="fadeSlide: $data"></div>'
    expect(() -> ko.applyBindings {}, testNode).toThrow()
