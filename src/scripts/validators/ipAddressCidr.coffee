if libraries.knockoutValidation
  # http://labs.spritelink.net/regex
  ko.validation.rules.ipAddressCidr =
    validator: (value) ->
      if value
        return value.match(/^((2(5[0-5]|[0-4][0-9])|[01]?[0-9][0-9]?)\.){3}(2(5[0-5]|[0-4][0-9])|[01]?[0-9][0-9]?)\/(3[012]|[12]?[0-9])$/i)
      true
    message: 'Please enter a valid IPv4 CIDR (ex: 10.189.12.0/24).'
