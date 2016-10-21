ko.components.register 'toggle', {
    viewModel: {
      createViewModel: (params, componentInfo) ->
        return new ToggleViewModel(params, componentInfo.element)
    },
  template: {
      element: "cyclops.toggle"
  }
}
