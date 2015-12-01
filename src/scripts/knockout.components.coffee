ko.components.register 'slider', {
    viewModel: SliderViewModel,
    template: {
        element: "cyclops.slider"
    }
}

ko.components.register 'toggle', {
    viewModel: ToggleViewModel,
    template: {
        element: "cyclops.toggle"
    }
}

ko.components.register 'group-picker', {
    viewModel: GroupPickerViewModel,
    template: {
        element: "cyclops.groupPicker"
    }
}

ko.components.register 'server-picker', {
    viewModel: ServerPickerViewModel,
    template: {
        element: "cyclops.serverPicker"
    }
}
