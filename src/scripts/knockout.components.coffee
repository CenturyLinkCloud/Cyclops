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

ko.components.register 'show-password', {
    viewModel: ShowPasswordViewModel,
    template: {
        element: "cyclops.showPassword"
    }
}

ko.components.register 'account-switcher', {
    viewModel: AccountSwitcherViewModel,
    template: {
        element: "cyclops.accountSwitcher"
    }
}


ko.components.register 'date-time-picker', {
    viewModel: DateTimePickerViewModel,
    template: {
        element: "cyclops.dateTimePicker"
    }
}
