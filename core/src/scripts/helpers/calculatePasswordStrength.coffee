helpers.calculatePasswordStrength = (password) ->
  upper = /[A-Z]/
  lower = /[a-z]/
  number = /[0-9]/
  special = /[\~\!\@\#\$\%\^\&\*\_\-\+\=\|\\\(\)\{\}\[\]\:<>\,\.\?\/]/
  charTypes = 0
  strength = 0
  if lower.test(password)
    charTypes++
  if upper.test(password)
    charTypes++
  if number.test(password)
    charTypes++
  if special.test(password)
    charTypes++
  if password.length < 8
    strength = 0
  else if charTypes < 3
    strength = 1
  else if password.length == 8 and charTypes == 3
    strength = 2
  else if password.length >= 9 and charTypes == 3
    strength = 3
  else if password.length >= 9 and charTypes == 4
    strength = 4
  else
    strength = 0
  strength
