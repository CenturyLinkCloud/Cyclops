class CopyableInput

  constructor: (@element) ->
    unless @element.tagName is 'INPUT'
      throw 'CopyableInput may only be used with <input> elements!'

    ($ @element).addClass('copyable-input')

    @insertCopyButton()
    @addEventListeners()

  insertCopyButton: ->
    @copyButtonElement = $('<button title="Copy to Clipboard"><svg class="cyclops-icon" aria-hidden="true"><use xlink:href="#icon-clipboard" /></svg></button>')
    @copyButtonElement.insertAfter(@element)

    # Resize the input to make space for the button without changing the
    # overall width of the combined input+button.
    inputWidth = ($ @element).innerWidth()
    buttonWidth = @copyButtonElement.innerWidth()
    newInputWidth = inputWidth - buttonWidth
    ($ @element).css('width', newInputWidth)

  addEventListeners: ->
    @copyButtonElement.on('click', @onClick)

  onClick: (event) =>
    inputValue = @element.value

    # console.log '[CopyableInput] Input Value:', inputValue

    event.preventDefault()
    event.stopPropagation()

    @copyToClipboard(inputValue)

  copyToClipboard: (value) ->
    # console.log '[CopyableInput] Copying Value to Clipboard...', value

    temporaryElement = document.createElement('div')
    temporaryElement.innerText = value
    temporaryElement.style.position = 'absolute'
    temporaryElement.style.left = '-10000px'
    temporaryElement.style.top = '-10000px'
    document.body.appendChild(temporaryElement)

    selection = getSelection()
    range = document.createRange()
    selection.removeAllRanges()
    range.selectNodeContents(temporaryElement)
    selection.addRange(range)
    document.execCommand('copy', false, null)
    selection.removeAllRanges()

    temporaryElement.parentElement.removeChild(temporaryElement)

$.fn.copyableInput = (options) ->
  options = $.extend { }, options
  $(this).each (idx, input) ->
    copyableInputInstance = new CopyableInput(input)
  $(this)
