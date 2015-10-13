describe 'Validators: uri', ->
  it 'it hangs off the global rules object', ->
    expect(ko.validation.rules.uri).toBeDefined()
    return
  it 'returns true for valid urls with no scheme', ->
    expect(ko.validation.rules.uri.validator('http://www.tier3.com')).toBeTruthy()
    expect(ko.validation.rules.uri.validator('http://www.tier3.com/app')).toBeTruthy()
    expect(ko.validation.rules.uri.validator('http://www.tier3.com:123')).toBeTruthy()
    expect(ko.validation.rules.uri.validator('http://www.tier3.com:123/app')).toBeTruthy()
    expect(ko.validation.rules.uri.validator('https://www.tier3.com')).toBeTruthy()
    expect(ko.validation.rules.uri.validator('https://www.tier3.com/app')).toBeTruthy()
    expect(ko.validation.rules.uri.validator('https://www.tier3.com:123')).toBeTruthy()
    expect(ko.validation.rules.uri.validator('https://www.tier3.com:123/app')).toBeTruthy()
    expect(ko.validation.rules.uri.validator('ftp://www.tier3.com')).toBeTruthy()
    expect(ko.validation.rules.uri.validator('ftp://www.tier3.com/app')).toBeTruthy()
    expect(ko.validation.rules.uri.validator('ftp://www.tier3.com:123')).toBeTruthy()
    expect(ko.validation.rules.uri.validator('ftp://www.tier3.com:123/app')).toBeTruthy()
    return

  it 'returns true for valid urls with scheme', ->
    expect(ko.validation.rules.uri.validator('http://www.tier3.com', {scheme: 'http'})).toBeTruthy()
    expect(ko.validation.rules.uri.validator('http://www.tier3.com/app', {scheme: 'http'})).toBeTruthy()
    expect(ko.validation.rules.uri.validator('http://www.tier3.com:123', {scheme: 'http'})).toBeTruthy()
    expect(ko.validation.rules.uri.validator('http://www.tier3.com:123/app', {scheme: 'http'})).toBeTruthy()
    expect(ko.validation.rules.uri.validator('https://www.tier3.com', {scheme: 'https'})).toBeTruthy()
    expect(ko.validation.rules.uri.validator('https://www.tier3.com/app', {scheme: 'https'})).toBeTruthy()
    expect(ko.validation.rules.uri.validator('https://www.tier3.com:123', {scheme: 'https'})).toBeTruthy()
    expect(ko.validation.rules.uri.validator('https://www.tier3.com:123/app', {scheme: 'https'})).toBeTruthy()
    expect(ko.validation.rules.uri.validator('ftp://www.tier3.com', {scheme: 'ftp'})).toBeTruthy()
    expect(ko.validation.rules.uri.validator('ftp://www.tier3.com/app', {scheme: 'ftp'})).toBeTruthy()
    expect(ko.validation.rules.uri.validator('ftp://www.tier3.com:123', {scheme: 'ftp'})).toBeTruthy()
    expect(ko.validation.rules.uri.validator('ftp://www.tier3.com:123/app', {scheme: 'ftp'})).toBeTruthy()
    return

  it 'returns false for valid urls with scheme does match', ->
    expect(ko.validation.rules.uri.validator('http://www.tier3.com', {scheme: 'https'})).toBeFalsy()
    expect(ko.validation.rules.uri.validator('http://www.tier3.com/app', {scheme: 'https'})).toBeFalsy()
    expect(ko.validation.rules.uri.validator('http://www.tier3.com:123', {scheme: 'https'})).toBeFalsy()
    expect(ko.validation.rules.uri.validator('http://www.tier3.com:123/app', {scheme: 'https'})).toBeFalsy()
    expect(ko.validation.rules.uri.validator('https://www.tier3.com', {scheme: 'http'})).toBeFalsy()
    expect(ko.validation.rules.uri.validator('https://www.tier3.com/app', {scheme: 'http'})).toBeFalsy()
    expect(ko.validation.rules.uri.validator('https://www.tier3.com:123', {scheme: 'http'})).toBeFalsy()
    expect(ko.validation.rules.uri.validator('https://www.tier3.com:123/app', {scheme: 'http'})).toBeFalsy()
    expect(ko.validation.rules.uri.validator('ftp://www.tier3.com', {scheme: 'ftps'})).toBeFalsy()
    expect(ko.validation.rules.uri.validator('ftp://www.tier3.com/app', {scheme: 'ftps'})).toBeFalsy()
    expect(ko.validation.rules.uri.validator('ftp://www.tier3.com:123', {scheme: 'ftps'})).toBeFalsy()
    expect(ko.validation.rules.uri.validator('ftp://www.tier3.com:123/app', {scheme: 'ftps'})).toBeFalsy()
    return
  it 'returns false for invalid urls with no scheme', ->
    expect(ko.validation.rules.uri.validator('www.tier3.com')).toBeFalsy()
    expect(ko.validation.rules.uri.validator('www.tier3.com/app')).toBeFalsy()
    expect(ko.validation.rules.uri.validator('www.tier3.com:123')).toBeFalsy()
    expect(ko.validation.rules.uri.validator('www.tier3.com:123/app')).toBeFalsy()
    expect(ko.validation.rules.uri.validator('tier3.com')).toBeFalsy()
    expect(ko.validation.rules.uri.validator('tier3.com/app')).toBeFalsy()
    expect(ko.validation.rules.uri.validator('tier3.com:123')).toBeFalsy()
    expect(ko.validation.rules.uri.validator('tier3.com:123/app')).toBeFalsy()
    expect(ko.validation.rules.uri.validator('ftp://')).toBeFalsy()
    expect(ko.validation.rules.uri.validator('completely wrong')).toBeFalsy()
    return

  return
