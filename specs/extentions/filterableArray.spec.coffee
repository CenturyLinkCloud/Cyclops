describe 'Extentions: filterableArray', ->
  it 'hangs off the global knockout object', ->
    expect(ko.filterableArray).toBeDefined()
    return

  it 'default properties', ->
    filterable = ko.filterableArray []
    expect(filterable.isFilterableArray).toBeDefined()
    expect(filterable.query).toBeDefined()
    expect(filterable.all).toBeDefined()
    expect(filterable.sortByString).toBeDefined()
    expect(filterable.sortByStringDesc).toBeDefined()
    expect(filterable.isSorting).toBeDefined()
    expect(filterable.clearSort).toBeDefined()
    expect(filterable.pop).toBeDefined()
    expect(filterable.push).toBeDefined()
    expect(filterable.reverse).toBeDefined()
    expect(filterable.shift).toBeDefined()
    expect(filterable.sort).toBeDefined()
    expect(filterable.splice).toBeDefined()
    expect(filterable.unshift).toBeDefined()
    expect(filterable.slice).toBeDefined()
    expect(filterable.replace).toBeDefined()
    expect(filterable.indexOf).toBeDefined()
    expect(filterable.destroy).toBeDefined()
    expect(filterable.destroyAll).toBeDefined()
    expect(filterable.remove).toBeDefined()
    expect(filterable.removeAll).toBeDefined()
    return

  it 'defaults to filtered array read but has whole array avalible', ->
    filterable = ko.filterableArray ['one', 'two', 'three']
    filterable.query('three')
    expect(filterable().length).toEqual(1)
    expect(filterable.all().length).toEqual(3)
    return

  it 'uses passed observable for all array', ->
    initValues = ko.observableArray ['one', 'two', 'three']
    filterable = ko.filterableArray initValues
    expect(filterable.all).toEqual(initValues)
    return

  it '[default comparer] uses simple contains for strings', ->
    filterable = ko.filterableArray ['one', 'two', 'three']
    filterable.query('o')
    expect(filterable().length).toEqual(2)
    filterable.query('t')
    expect(filterable().length).toEqual(2)
    filterable.query('th')
    expect(filterable().length).toEqual(1)
    return

  it '[default comparer] is case insensative for strings', ->
    filterable = ko.filterableArray ['ONE']
    filterable.query('one')
    expect(filterable().length).toEqual(1)
    return

  it '[default comparer] falls back to strict equal, with tostring on item', ->
    filterable = ko.filterableArray [1,2,3]
    filterable.query('3')
    expect(filterable().length).toEqual(1)
    return

  it '[default comparer] throws if query is not string', ->
    filterable = ko.filterableArray [1,2,3]
    expect(filterable.query(3)).toThrow()
    return

  it '[default comparer] object uses field names', ->
    filterable = ko.filterableArray [{
        name: 'the name'
        description: 'the description'
        id: 'theId'
        notUsed: 'not used for search'
      }]
    filterable.query('name')
    expect(filterable().length).toEqual(1)
    filterable.query('description')
    expect(filterable().length).toEqual(1)
    filterable.query('theid')
    expect(filterable().length).toEqual(1)
    filterable.query('search')
    expect(filterable().length).toEqual(0)
    return

  it '[default comparer] object unwraps observables', ->
    filterable = ko.filterableArray [{
        name: ko.observable('the name')
      }]
    filterable.query('name')
    expect(filterable().length).toEqual(1)
    filterable([ko.observable('one'), ko.observable('two')])
    filterable.query('on')
    expect(filterable().length).toEqual(1)
    return

  it '[default comparer] fields can be changed', ->
    filterable = ko.filterableArray [{
        notDefault: 'not the default field'
      }], {fields: ['notDefault']}
    filterable.query('not the d')
    expect(filterable().length).toEqual(1)
    return

  it '[default comparer] object uses field names', ->
    filterable = ko.filterableArray [{
        name: {
          first: 'john'
          last: 'smith'
        }
      }], {fields: ['name', 'first']}
    filterable.query('john')
    expect(filterable().length).toEqual(1)
    filterable.query('smith')
    expect(filterable().length).toEqual(0)
    return

  it 'can have the comparer changed', ->
    filterable = ko.filterableArray ['one', 'two', 'three'],
      { comparer: (query, item ) ->
          return true;
      }
    filterable.query('o')
    expect(filterable().length).toEqual(3)
    filterable.query('two')
    expect(filterable().length).toEqual(3)
    return

  it 'removes last item from all and filtered when pop called', ->
    filterable = ko.filterableArray ['one', 'two', 'three']
    filterable.query('t')
    expect(filterable.all().length).toEqual(3)
    expect(filterable().length).toEqual(2)
    filterable.pop()
    expect(filterable.all().length).toEqual(2)
    expect(filterable.all()[1]).toEqual('two')
    expect(filterable().length).toEqual(1)
    expect(filterable()[0]).toEqual('two')
    return

  it 'returns a reversed array when reverse called', ->
    filterable = ko.filterableArray ['one', 'two', 'three']
    filterable.query('t')
    expect(filterable()[0]).toEqual('two')
    expect(filterable()[1]).toEqual('three')
    filterable.reverse()
    expect(filterable()[0]).toEqual('three')
    expect(filterable()[1]).toEqual('two')
    return

  it 'returns array including item just pushed at the end', ->
    filterable = ko.filterableArray ['one', 'two', 'three']
    filterable.query('t')
    expect(filterable().length).toEqual(2)
    filterable.push('thirty')
    expect(filterable()[0]).toEqual('two')
    expect(filterable()[1]).toEqual('three')
    expect(filterable()[2]).toEqual('thirty')
    return

  it 'removes first item from all and filtered when shift called', ->
    filterable = ko.filterableArray ['two', 'three', 'four']
    filterable.query('t')
    expect(filterable.all().length).toEqual(3)
    expect(filterable().length).toEqual(2)
    filterable.shift()
    expect(filterable.all().length).toEqual(2)
    expect(filterable.all()[1]).toEqual('four')
    expect(filterable().length).toEqual(1)
    expect(filterable()[0]).toEqual('three')
    return


  it 'has sort that takes a comparer function order order the array', ->
    filterable = ko.filterableArray [10, 1, 2.5, 15]
    filterable.sort( (a, b) ->
      return a - b
    )
    expect(filterable()[0]).toEqual(1)
    expect(filterable()[1]).toEqual(2.5)
    expect(filterable()[2]).toEqual(10)
    expect(filterable()[3]).toEqual(15)
    return

  it 'removes items at index from all and filtered when splice called', ->
    filterable = ko.filterableArray ['one', 'two', 'three', 'four']
    filterable.query('o')
    #dont remove anything
    filterable.splice(1,0)
    expect(filterable().length).toEqual(3)
    expect(filterable.all().length).toEqual(4)
    #remove two and three
    filterable.splice(0,2)
    expect(filterable().length).toEqual(1)
    expect(filterable.all().length).toEqual(2)
    return

  it 'adds items at index from all and filtered when splice called', ->
    filterable = ko.filterableArray ['one', 'three', 'four']
    filterable.query('o')
    filterable.splice(0, 0, 'two')
    expect(filterable().length).toEqual(3)
    expect(filterable.all().length).toEqual(4)
    return

  it 'returns array including item just unshifted at the begining', ->
    filterable = ko.filterableArray ['one', 'two', 'three']
    filterable.query('o')
    expect(filterable().length).toEqual(2)
    filterable.unshift('zero')
    expect(filterable.all()[0]).toEqual('zero')
    expect(filterable.all()[1]).toEqual('one')
    expect(filterable.all()[2]).toEqual('two')
    expect(filterable.all()[3]).toEqual('three')
    expect(filterable()[0]).toEqual('zero')
    expect(filterable()[1]).toEqual('one')
    expect(filterable()[2]).toEqual('two')
    return

  it 'sorts by correct property when items are objects', ->
    filterable = ko.filterableArray [{id: '3'}, {id: '1'}, {id: '5'}]
    filterable.sortByString('id')
    expect(filterable()[0].id).toEqual('1')
    expect(filterable()[1].id).toEqual('3')
    expect(filterable()[2].id).toEqual('5')
    return

  it 'sorts by correct property when items are objects desc version', ->
    filterable = ko.filterableArray [{id: '3'}, {id: '1'}, {id: '5'}]
    filterable.sortByStringDesc('id')
    expect(filterable()[0].id).toEqual('5')
    expect(filterable()[1].id).toEqual('3')
    expect(filterable()[2].id).toEqual('1')
    return

  it 'sorts even when items are added and removed', ->
    filterable = ko.filterableArray [{id: '3'}, {id: '1'}, {id: '5'}]
    filterable.sortByStringDesc('id')
    filterable.push({id: '6'})
    expect(filterable()[0].id).toEqual('6')
    filterable.shift()
    expect(filterable()[0].id).toEqual('5')

  it 'should pass through observableArray function to all', ->
    filterable = ko.filterableArray []
    spyOn filterable.all, 'slice'
    spyOn filterable.all, 'replace'
    spyOn filterable.all, 'indexOf'
    spyOn filterable.all, 'destroy'
    spyOn filterable.all, 'destroyAll'
    spyOn filterable.all, 'remove'
    spyOn filterable.all, 'removeAll'

    filterable.slice([1])
    expect(filterable.all.slice).toHaveBeenCalledWith([1])
    filterable.replace('a', 'b')
    expect(filterable.all.replace).toHaveBeenCalledWith('a', 'b')
    filterable.indexOf({a:'a'})
    expect(filterable.all.indexOf).toHaveBeenCalledWith({a:'a'})
    filterable.destroy({})
    expect(filterable.all.destroy).toHaveBeenCalledWith({})
    filterable.destroyAll([{a:'a'}])
    expect(filterable.all.destroyAll).toHaveBeenCalledWith([{a:'a'}])
    filterable.remove([{a:'a'}])
    expect(filterable.all.remove).toHaveBeenCalledWith([{a:'a'}])
    filterable.removeAll([{a:'a'}])
    expect(filterable.all.removeAll).toHaveBeenCalledWith([{a:'a'}])

  return
