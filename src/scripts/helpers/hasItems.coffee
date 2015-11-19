helpers.hasItems = (data) ->
  data = ko.unwrap(data)
  return data and data.length and data.length > 0
