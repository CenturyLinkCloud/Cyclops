class CopyableInput

  constructor: (@element) ->
    unless @element.tagName is 'INPUT'
      throw 'CopyableInput may only be used with <input> elements!'

    ($ @element).addClass('copyable-input')

    @insertCopyButton()
    @addEventListeners()

  insertCopyButton: ->
    # @copyButtonElement = $('<button title="Copy to Clipboard">Copy</button>')
    @copyButtonElement = $('<button title="Copy to Clipboard"><svg class="cyclops-icon" aria-hidden="true"><use xlink:href="#icon-clipboard" /></svg></button>')

    @copyButtonElement.insertAfter(@element)

    # Resize the input to make space for the button without changing the
    # overall width of the combined input+button.
    inputWidth = ($ @element).innerWidth()
    buttonWidth = @copyButtonElement.innerWidth()
    newInputWidth = inputWidth - buttonWidth
    ($ @element).css('width', newInputWidth)

  addEventListeners: ->
    @copyButtonElement.on('click', @copyToClipboard)

  copyToClipboard: (event) =>
    @element.focus()

    document.execCommand('selectAll')
    document.execCommand('copy', false, null)
    document.execCommand('unselect')

    @element.blur()

    event.preventDefault()
    event.stopPropagation()

$.fn.copyableInput = (options) ->
  options = $.extend { }, options
  $(this).each (idx, input) ->
    copyableInputInstance = new CopyableInput(input)
  $(this)
