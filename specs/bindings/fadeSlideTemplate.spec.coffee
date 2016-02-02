describe 'Bindings: fadeSlideTemplate', ->
  beforeEach jasmine.prepareTestNode

  it 'is defined', ->
    expect(ko.bindingHandlers.fadeSlideTemplate).toBeDefined()

  it 'throws error when passing object with no name property', ->
    testNode.innerHTML = '<div data-bind="fadeSlide: $data"></div>'
    expect(() -> ko.applyBindings {}, testNode).toThrow()
