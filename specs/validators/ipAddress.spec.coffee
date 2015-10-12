describe 'Validators: ipAddress', ->
  it 'it hangs off the global rules object', ->
    expect(ko.validation.rules.ipAddress).toBeDefined()
    return

  it 'true for valid IPv4 Addresses', ->
    expect(ko.validation.rules.ipAddress.validator('192.168.1.1')).toBeTruthy()
    expect(ko.validation.rules.ipAddress.validator('1.1.1.1')).toBeTruthy()
    expect(ko.validation.rules.ipAddress.validator('255.255.0.0')).toBeTruthy()
    return

  it 'false for non IPv4 Addresses', ->
    expect(ko.validation.rules.ipAddress.validator('168.1.1')).toBeFalsy()
    expect(ko.validation.rules.ipAddress.validator('fe80:0000:0000:0000:0204:61ff:fe9d:f156')).toBeFalsy()
    expect(ko.validation.rules.ipAddress.validator('fe80::204:61ff:254.157.241.86')).toBeFalsy()
    expect(ko.validation.rules.ipAddress.validator('not an IP')).toBeFalsy()
    return

  return
