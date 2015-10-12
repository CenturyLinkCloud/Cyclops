describe 'Validators: ipAddressCidr', ->
  it 'it hangs off the global rules object', ->
    expect(ko.validation.rules.ipAddressCidr).toBeDefined()
    return

  it 'true for valid IPv4 cidr', ->
    expect(ko.validation.rules.ipAddressCidr.validator('192.168.1.0/32')).toBeTruthy()
    expect(ko.validation.rules.ipAddressCidr.validator('1.1.1.0/24')).toBeTruthy()
    return

  it 'false for non IPv4 cidr', ->
    expect(ko.validation.rules.ipAddressCidr.validator('168.1.1')).toBeFalsy()
    expect(ko.validation.rules.ipAddressCidr.validator('fe80:0000:0000:0000:0204:61ff:fe9d:f156')).toBeFalsy()
    expect(ko.validation.rules.ipAddressCidr.validator('192.168.1.0/123')).toBeFalsy()
    expect(ko.validation.rules.ipAddressCidr.validator('not an IP')).toBeFalsy()
    return
  return
