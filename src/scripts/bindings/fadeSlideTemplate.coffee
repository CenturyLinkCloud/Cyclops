ko.bindingHandlers.fadeSlideTemplate =
  init: (element, valueAccessor, allBindings) ->
    ko.bindingHandlers['template']['init'] element, valueAccessor, allBindings
  update: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
    # make sure we get subscribed
    value = ko.unwrap valueAccessor()
    if typeof value == 'object'
      value.name = ko.unwrap value.name
      if !value.name
        throw 'When using the fadeSlideTemaple binding and passing an object there must be a property "name" that defines the template to use.'


    $element = $(element)
    fromHeight = $element.height()
    # we create a new value Accessor to keep the subscription from happening on the template binding
    # because we always want to be the one called and we will call the template update.
    newValueAccessor = () ->
      return value

    # if the height is 0 just show the template becuase it's likely the first time something is rendered
    if(fromHeight == 0)
      ko.bindingHandlers['template']['update'] element, newValueAccessor, allBindings, viewModel, bindingContext
    # animate the transition in height and fade in the new content
    else
      # For this animation we just want to hdie the old content right away
      $element.css {'overflow': 'hidden', 'opacity': 0 }

      # render the new template
      ko.bindingHandlers['template']['update'] element, newValueAccessor, allBindings, viewModel, bindingContext

      # get the new height and then set it immeditally back to the old height for the animation
      toHeight = $element.height()
      $element.height fromHeight

      # do the animation
      $element.animate { opacity: 1, height: toHeight }, {
        duration: 300
        complete: () ->
          # set the styles back to the defaults
          $element.css { height: 'auto', overflow: 'auto' }
      }

    return
