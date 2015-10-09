helpers.containsAny = (value, possibilitiesArray) ->
  ps = ko.unwrap(possibilitiesArray)
  if typeof ps == 'string'
    ps = ps.split('')
  if !$.isArray(ps)
    throw 'Possibilities must me an array or string, they may be observable'
  ps = $.unique(ps)
  contained = []
  ps.forEach (c) ->
    if value.indexOf(c) >= 0
      contained.push c
    return
  contained
