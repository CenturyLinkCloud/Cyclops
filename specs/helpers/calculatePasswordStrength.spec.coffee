describe 'helpers: calculatePasswordStrength', ->
  it 'it hangs off the internal helpers object', ->
    expect(helpers.calculatePasswordStrength).toBeDefined()
    return
  it 'returns 0 for passwords less than 8 characters even with multiple char types', ->
    expect(helpers.calculatePasswordStrength('1$Ab')).toEqual(0)
    return
  it 'returns 1 for passwords greater than 8 characters with less than 2 char types', ->
    expect(helpers.calculatePasswordStrength('aAaAaAaA')).toEqual(1)
    return
  it 'returns 2 for 8 character passwords with 3 char types', ->
    expect(helpers.calculatePasswordStrength('aA!AaAaA')).toEqual(2)
    return
  it 'returns 3 for 9 character passwords with 3 char types', ->
    expect(helpers.calculatePasswordStrength('aA!AaAaAa')).toEqual(3)
    return

  it 'returns 2 for 8 character passwords with 3 char types', ->
    expect(helpers.calculatePasswordStrength('Admin123')).toEqual(2)
    return

  it 'returns 4 for 10 character passwords with 4 char types', ->
    expect(helpers.calculatePasswordStrength('1!Ab1!Ab#$')).toEqual(4)
    return
  it 'returns 4 for 9 character passwords with 4 char types', ->
    expect(helpers.calculatePasswordStrength('1!Ab1!Ab#')).toEqual(4)
    return
  return
