_sortBy = (array, propName, isDesc) ->
    array.sort (a,b) ->
      propA = ko.unwrap(a[propName])
      propB = ko.unwrap(b[propName])
      if propA? and propB?
        if (propA > propB)
          return if isDesc then -1 else 1
        else if (propA < propB)
          return if isDesc then 1 else -1
        else
          return 0
      else
        throw 'each item in the array must have the property you are sorting on'
    return array


ko.filterableArray = (initValues, options) ->
  #TODO: what defaults do we want to support for fields?
  options = $.extend({
    fields: ['name', 'description', 'id']
    comparer: (query, item) ->
      item = ko.unwrap(item)
      if typeof query != 'string'
        throw 'The default comparer only supports string queries, you can provide your own
          comparer to support object queries'
      query = query.toLowerCase();
      if(typeof item == 'string')
        return item.toLowerCase().indexOf(query) > -1
      else if (typeof item == 'object')
        match = false;
        options.fields.forEach (p) ->
          if item.hasOwnProperty(p) and options.comparer(query, item[p])
            match = true
        return match
      else
        return query == item.toString();
  }, options);

  result = ko.pureComputed  {
    read: () ->
      if result._sorter()?
        result.all.sort(result._sorter());
      if result.query()
        query = result.query()
        return result.all().filter (value) ->
          return options.comparer(query, value)
      return result.all()
    write: (value) ->
      result.all(value)
  }

  result.all = ko.asObservableArray(initValues)
  result.query = ko.observable()
  result._sorter = ko.observable(null)
  result.isSorting = ko.pureComputed () ->
    return result._sorter()?
  result.clearSort = () ->
    result._sorter(null);
  result.isFilterableArray = true
  # just used to mark this as an array since this is how most people for for arraies
  result.length = 0

  result.sortByString = (propName) ->
    result._sorter((a, b) ->
      propA = ko.unwrap(a[propName])
      propB = ko.unwrap(b[propName])
      if propA? and propB?
        if (propA > propB)
          return  1
        else if (propA < propB)
          return -1
        else
          return 0
      else
        throw 'each item in the array must have the property you are sorting on'
    )

  result.sortByStringDesc = (propName) ->
    result._sorter((a, b) ->
      propA = ko.unwrap(a[propName])
      propB = ko.unwrap(b[propName])
      if propA? and propB?
        if (propA > propB)
          return  -1
        else if (propA < propB)
          return 1
        else
          return 0
      else
        throw 'each item in the array must have the property you are sorting on'
    )

  result.sort  = (func) ->
    if func?
      result._sorter(func);
    else
      throw 'you need to specify a sort function when using sort on a filterableArray'


  ['pop', 'push', 'reverse',
   'shift', 'splice',
   'unshift', 'slice', 'replace',
   'indexOf', 'destroy', 'destroyAll',
   'remove', 'removeAll'].forEach (method) ->
    result[method] = () ->
      return result.all[method].apply(result.all, arguments)


  result
