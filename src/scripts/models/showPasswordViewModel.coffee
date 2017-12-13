class ShowPasswordViewModel
  constructor: (params) ->
    if params.getPassword == null || typeof params.getPassword != 'function'
      throw 'A parameter \'getPassword\' is required and must be a function'

    @loading = ko.observable false
    @errored = ko.observable false
    @showPassword = ko.observable false
    @timer = null
    @password = ko.observable ''


    @fetchPassword = () =>
      @loading true
      @errored false
      @showPassword true
      result = params.getPassword()
      if helpers.isDeferred result
        # Set timer once it's done loading
        result.always () =>
          @loading false
        result.fail () =>
          @errored true
        result.done (result) =>
          if typeof result == 'object'
            @password result.password
          else
            @password result
      else
        @loading(false)
        @errored(false)
        if typeof result == 'object'
          @password result.password
        else
          @password result

    @retryHandler = () =>
      @fetchPassword()
      return false

    @clickHandler = () =>
      if @showPassword()
        @showPassword false
        @errored false
        @loading false
      else
        @fetchPassword()
      return false;

    @mouseOver = () =>
      if @timer
        clearTimeout @timer

    @mouseExit = () =>
      if @showPassword() && !@loading()
        @timer = setTimeout () =>
          @showPassword false
          @errored false
          @loading false
        , 15000
