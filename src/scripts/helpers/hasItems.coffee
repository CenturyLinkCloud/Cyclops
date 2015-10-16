helpers.hasItems = (data) ->
  data = ko.unwrap(data)
  return data.length and data.length > 0
